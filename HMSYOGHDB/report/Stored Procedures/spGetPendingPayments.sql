-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetPendingPayments] --1,1
(
@LocationID int,
@DrawerID int
)
AS
BEGIN

    DECLARE @HotelName VARCHAR(50)=(SELECT LocationName from [general].[Location] where LocationID=@LocationID)
	DECLARE @HotelCode VARCHAR(20)=(SELECT LocationCode from [general].[Location] where LocationID=@LocationID)
	DECLARE @PrintedOn VARCHAR(20)=Format(GETDATE(),'dd-MMM-yyyy hh:mm tt')
	
	DECLARE @PaidAmount TABLE(ReservationID INT, PaidAmount DECIMAL(18,4))
	DECLARE @TotalAmount TABLE(ReservationID INT, TotalAmount DECIMAL(18,4))
	DECLARE @ComplementaryAmount TABLE(ReservationID INT, ComplimentaryAmount DECIMAL(18,4))

	INSERT INTO @PaidAmount(ReservationID, PaidAmount)
	SELECT rn.ReservationID, ISNULL(SUM(Amount),0) FROM [reservation].[Reservation] rn
	LEFT JOIN [guest].[GuestWallet] gw ON rn.ReservationID = gw.ReservationID AND AccountTypeID NOT IN (7,12,14,20,50,82,83,84,85) AND IsVoid <> 1 
	WHERE rn.LocationID = @LocationID
	GROUP BY rn.ReservationID

	INSERT INTO @TotalAmount(ReservationID, TotalAmount)
	SELECT rn.ReservationID, ISNULL(SUM(rt.Rate -((Percentage/100)*rt.Rate)),0)  FROM [reservation].[Reservation] rn
	INNER JOIN [reservation].[ReservedRoom] rm ON rn.ReservationID = rm.ReservationID 
	INNER JOIN [reservation].[RoomRate] rt ON rm.ReservedRoomID = rt.ReservedRoomID
	INNER JOIN [reservation].[Discount] dis ON rt.DiscountID = dis.DiscountID	
	WHERE rn.LocationID = @LocationID AND rt.IsVoid <> 1
	GROUP BY rn.ReservationID 
	
	INSERT INTO @ComplementaryAmount(ReservationID, ComplimentaryAmount)
	SELECT  rn.ReservationID,  ISNULL(SUM(gw.Amount),0)
	FROM [reservation].[Reservation] rn
	LEFT JOIN	guest.GuestWallet gw  ON rn.ReservationID = gw.ReservationID  AND gw.AccountTypeID = 20
	WHERE rn.LocationID = @LocationID 
	GROUP BY rn.ReservationID 

	
	SELECT (l.LocationCode + CAST(re.FolioNumber as varchar(20))) [FolioNumber]
	,CONCAT(d.FirstName,' ',d.LastName) [GuestName]
	,r.RoomNo [RoomNo]
	,CAST(TotalAmount - ComplimentaryAmount as decimal(18,2)) [TotalAmount]
	,CAST(PaidAmount as decimal(18,2)) [Paid]
	,CAST(TotalAmount - ComplimentaryAmount - PaidAmount as decimal(18,2)) [Balance]
	,@HotelName [HotelName]
	,@HotelCode [HotelCode]
	,@PrintedOn [PrintedOn]
	,rm.RateCurrencyID
	FROM [general].[Location] l
	INNER JOIN [reservation].[Reservation] re ON l.LocationID = re.LocationID
	INNER JOIN [reservation].[ReservedRoom] rm ON re.ReservationID = rm.ReservationID
	INNER JOIN @TotalAmount tm ON re.ReservationID = tm.ReservationID
	INNER JOIN @PaidAmount pm ON re.ReservationID = pm.ReservationID
	INNER JOIN @ComplementaryAmount cm ON re.ReservationID = cm.ReservationID
	INNER JOIN [guest].[Guest] g ON re.GuestID = g.GuestID
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID	
	INNER JOIN [room].[Room] r ON rm.RoomID = r.RoomID	
    WHERE re.LocationID = @LocationID 
	AND (TotalAmount - ComplimentaryAmount - PaidAmount) > 0
	
	
	
END

