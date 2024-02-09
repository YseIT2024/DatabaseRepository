
CREATE PROCEDURE [dbo].[spGetDashBoard] --8, 1, '2021-02-05'
(
	@DrawerID int,
	@UserID int,
	@AccountingDate date = NULL
)
AS
BEGIN
	SET NOCOUNT ON 
	-- 1 -> Vacant
	-- 2 -> Reserved
	-- 3 -> House Keeping
	-- 4 -> Out Of Order
	-- 5 -> In House

	IF(@AccountingDate IS NULL)
	BEGIN
		SELECT @AccountingDate = AccountingDate FROM account.AccountingDates WHERE DrawerID = @DrawerID AND IsActive = 1;
	END

	DECLARE @LocationID INT = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	DECLARE @DateID int = (SELECT CAST(FORMAT(@AccountingDate,'yyyyMMdd') as int));
	DECLARE @TotalRooms int = (SELECT COUNT(RoomID) FROM room.Room WHERE LocationID = @LocationID);	
	DECLARE @Occupied int;	
	DECLARE @Available int;
	DECLARE @OutOfOrder int;	

	--DECLARE @YetToArrive int = 
	--(
	--	SELECT COUNT(r.RoomID) FROM room.Room r
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT RoomID 
	--		FROM [room].[RoomStatusHistory] 
	--		WHERE RoomStatusID = 2 AND FromDateID = @DateID
	--	)rsh ON r.RoomID = rsh.RoomID AND r.LocationID = @LocationID
	--);	

	--DECLARE @Arrived int =
	--(
	--	SELECT COUNT(r.RoomID) FROM room.Room r
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT RoomID 
	--		FROM [room].[RoomStatusHistory] 
	--		WHERE RoomStatusID = 5 AND FromDateID = @DateID
	--	)rsh ON r.RoomID = rsh.RoomID AND r.LocationID = @LocationID
	--);

	--DECLARE @YetToDeparture int =
	--(
	--	SELECT COUNT(r.RoomID) FROM room.Room r
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT RoomID 
	--		FROM [room].[RoomStatusHistory] 
	--		WHERE RoomStatusID = 5 AND ToDateID = @DateID
	--	)rsh ON r.RoomID = rsh.RoomID AND r.LocationID = @LocationID
	--);

	--DECLARE @Deported int =
	--(
	--	SELECT COUNT(r.RoomID) FROM room.Room r
	--	INNER JOIN 
	--	(
	--		SELECT DISTINCT RoomID 
	--		FROM [room].[RoomStatusHistory] 
	--		WHERE RoomStatusID = 8 AND ToDateID = @DateID
	--	)rsh ON r.RoomID = rsh.RoomID AND r.LocationID = @LocationID
	--);

	--DECLARE @Inhouse int =
	--(
	--	SELECT COUNT(r.ReservationID)
	--	FROM reservation.Reservation r
	--	INNER JOIN [room].[RoomStatusHistory] rsh ON r.ReservationID = rsh.ReservationID  
	--	WHERE ReservationStatusID = 3 AND LocationID = @LocationID AND (@DateID BETWEEN rsh.FromDateID AND rsh.ToDateID)
	--);

	DECLARE @YetToArrive int = 
	(
		SELECT COUNT(ReservationID) FROM reservation.Reservation
		WHERE LocationID = @LocationID AND CONVERT(DATE, ExpectedCheckIn) = @AccountingDate AND ActualCheckIn IS NULL
	)

	DECLARE @Arrived int =
	(
		SELECT COUNT(ReservationID) FROM reservation.Reservation
		WHERE LocationID = @LocationID AND CONVERT(DATE, ActualCheckIn) = @AccountingDate 
	)

	DECLARE @YetToDeparture int =
	(
		SELECT COUNT(ReservationID) FROM reservation.Reservation
		WHERE LocationID = @LocationID AND CONVERT(DATE, ExpectedCheckOut) = @AccountingDate AND ActualCheckOut IS NULL
	)

	DECLARE @Deported int =
	(
		SELECT COUNT(ReservationID) FROM reservation.Reservation
		WHERE LocationID = @LocationID AND CONVERT(DATE, ActualCheckOut) = @AccountingDate 
	)

	DECLARE @Inhouse int =
	(
		SELECT COUNT(ReservationID) FROM reservation.Reservation
		WHERE LocationID = @LocationID AND  @AccountingDate BETWEEN CONVERT(DATE, ActualCheckIn) AND  CONVERT(DATE, ExpectedCheckOut) 
	)

	SELECT 
	@Available = SUM(CASE WHEN PrimaryStatusID = 1 THEN 1 ELSE 0 END),
	@Occupied = SUM(CASE WHEN PrimaryStatusID = 2 THEN 1 ELSE 0 END),
	@OutOfOrder = SUM(CASE WHEN PrimaryStatusID = 4 THEN 1 ELSE 0 END)	
	FROM
	(
		SELECT r.RoomID, CASE WHEN rsh.PrimaryStatusID IN (2,5,8) THEN 2 WHEN rsh.PrimaryStatusID = 4 THEN 4 ELSE 1 END [PrimaryStatusID]
		From room.Room r
		LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS rsh ON r.RoomID = rsh.RoomID AND (@DateID BETWEEN rsh.FromDateID AND rsh.ToDateID)
		WHERE r.LocationID = @LocationID
	)t

	------------Table[0]--------------------------------------------------------------------------------------
	SELECT 
	(@YetToArrive + @Arrived) [Arrivals]
	,'Arrived: ' + CAST(@Arrived as varchar(7)) + '/' + CAST((@YetToArrive + @Arrived) as varchar(7)) [Arrived]
	,(@YetToDeparture + @Deported) [Departures]
	,'Deported: ' + CAST(@Deported as varchar(7)) + '/' + CAST((@YetToDeparture + @Deported) as varchar(7)) [Deported]
	,@Inhouse [InHouse]
	,'Stayovers: ' + CAST((@Inhouse - @YetToDeparture) as varchar(7)) + '/' + CAST(@Inhouse as varchar(7)) [Stayovers]
	,@Occupied [Occupied]
	,'Occupancy: ' + CAST(@Occupied as varchar(7)) + '/' + CAST(@TotalRooms as varchar(7)) [Occupancy]
	,@Available [Available]
	,'Availability: ' + CAST(CAST((@Available * 100 / @TotalRooms) as decimal(18,2)) as varchar(7)) + '%' [AvailableP]
	,@OutOfOrder [OutOfOrder]
	,'Percentage: ' + CAST(CAST((@OutOfOrder * 100 / @TotalRooms) as decimal(18,2)) as varchar(7)) + '%' [OutOfOrderP]

	------------Table[1] Room Status--------------------------------------------------------------------------
	SELECT tab.PrimaryStatus [Status], COUNT(tab.RoomID) [Number]
	FROM
	(
		SELECT DISTINCT r.RoomID
		,CASE WHEN roomStatus.PrimaryStatusID = 2 THEN 'Reserved' WHEN roomStatus.PrimaryStatusID = 4 THEN 'Out Of Order' 
		WHEN roomStatus.PrimaryStatusID = 5 THEN 'In House' ELSE 'Vacant' END [PrimaryStatus]
		From room.Room r
		LEFT JOIN  [room].[vwTodayRoomStatusHistory] AS roomStatus ON r.RoomID = roomStatus.RoomID AND (@DateID BETWEEN roomStatus.FromDateID AND roomStatus.ToDateID)
		WHERE r.LocationID = @LocationID
	) tab
	GROUP BY tab.PrimaryStatus

	------------Table[2] Guest----------------------------------------------------------------------------------
	SELECT tab.CountryName [Country], COUNT(tab.GuestID) [Guests]
	FROM
	(
		SELECT DISTINCT g.GuestID,c.CountryName
		FROM reservation.Reservation r
		INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
		INNER JOIN contact.Details d ON g.ContactID = d.ContactID
		INNER JOIN contact.[Address] a ON g.ContactID = a.ContactID AND a.IsDefault = 1 	
		INNER JOIN general.Country c ON a.CountryID = c.CountryID 
		WHERE R.LocationID = @LocationID
	)tab
	GROUP BY tab.CountryName

	-----------Table[3] Reservation per day in last 6 month----------------------------------------------------------------------
	SELECT tab.[DateTime] [Date], COUNT(tab.ReservationID) [Reservations]
	FROM
	(
		SELECT  r.ReservationID, CAST(r.[DateTime] as date) [DateTime]
		FROM reservation.Reservation r
		WHERE r.LocationID = @LocationID AND CAST(r.[DateTime] as date) BETWEEN CAST(DATEADD(DAY,-179,GETDATE()) as date) AND CAST(GETDATE() as date)
	)tab
	GROUP BY tab.[DateTime]

	------------Table[4] Guest's Date of birth---------------------------------------------------------------------
	SELECT DISTINCT d.FirstName + ISNULL(' ' + d.LastName, '') [GuestName]
	,FORMAT(d.DOB,'dd-MMM-yyyy') [DOB]
	,DATEDIFF(YYYY, d.DOB, GETDATE()) [Age]
	,CASE WHEN DATEPART(DD,d.DOB) = DATEPART(DD,CAST(DATEADD(DAY,-1,GETDATE())as date)) THEN 'Yesterday'
	WHEN DATEPART(DD,d.DOB) = DATEPART(DD,CAST(DATEADD(DAY,1,GETDATE())as date)) THEN 'Tomorrow' WHEN DATEPART(DD,d.DOB) = DATEPART(DD,GETDATE()) THEN 'Today' ELSE 'Upcoming' END [Status]
	FROM reservation.Reservation r
	INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
	INNER JOIN contact.Details d ON g.ContactID = d.ContactID
	WHERE CAST(FORMAT(d.DOB,'MMdd')as int) BETWEEN CAST(FORMAT(DATEADD(DAY,-1,GETDATE()),'MMdd')as int) AND CAST(FORMAT(DATEADD(DAY,14,GETDATE()),'MMdd')as int)
	AND r.LocationID = @LocationID

	------------Table[5] Exchange rate--------------------------------------------------------------------------------
	SELECT CurrencyCode, ExchangeRate 
	FROM currency.Currency c
	INNER JOIN currency.vwCurrentExchangeRate vwc ON c.CurrencyID = vwc.CurrencyID AND vwc.DrawerID = @DrawerID

	-------------Table[6] Vouvher to expire n 30 days
	SELECT [VoucherNumber]			
	,(l.LocationCode + CAST(r.FolioNumber as varchar(20))) [FolioNumber]
	,t.Title + ' ' + cd.FirstName + ' ' + ISNULL(cd.LastName,'') [GuestName]
	,c.CurrencySymbol + CAST(CAST([Amount] as decimal(18,2)) as varchar(12)) [Amount]	
	,FORMAT([ValidTo],'dd-MMM-yyyy') [ValidTo]	
	,CAST(DATEDIFF(DAY, GETDATE(), ValidTo) as varchar(3)) + ' day(s) remaining.' [Validity]	
	FROM [guest].[Voucher] v
	INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
	INNER JOIN guest.Guest g ON v.GuestID = g.GuestID
	INNER JOIN contact.Details cd ON g.ContactID = cd.ContactID
	INNER JOIN person.Title t ON cd.TitleID = t.TitleID
	INNER JOIN currency.Currency c ON v.CurrencyID = c.CurrencyID
	WHERE r.LocationID = @LocationID AND(GETDATE() BETWEEN v.ValidFrom AND v.ValidTo) AND v.RedeemOn IS NULL AND DATEDIFF(DAY, GETDATE(), ValidTo) <= 30
	ORDER BY [VoucherID] ASC
END
