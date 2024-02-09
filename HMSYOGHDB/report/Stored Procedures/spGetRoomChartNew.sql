
CREATE PROCEDURE [report].[spGetRoomChartNew] --'01-29-2020', '02-11-2020', 1
(
	@FromDate DATE,
	@ToDate DATE,
	@LocationID INT
)
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @FromDateID INT = (SELECT CAST(FORMAT(@FromDate,'yyyyMMdd') AS int));
	DECLARE @ToDateID INT = (SELECT CAST(FORMAT(@ToDate,'yyyyMMdd') AS int));
	DECLARE @cols AS NVARCHAR(MAX);
	DECLARE @query  AS NVARCHAR(MAX);

	SELECT @cols= COALESCE(@cols +',','') + QUOTENAME([DATE])
	FROM 
	(
		SELECT FORMAT([Date],'dd-MMM-yyyy') [Date]  
		FROM [general].[Date] WHERE DateID BETWEEN @FromDateID AND @ToDateID
	) AS tab

	CREATE TABLE temp_RoomChart(RoomID INT,RoomNo INT,RoomTypeID INT, RoomType VARCHAR(20), [Name] VARCHAR(200), [Date] VARCHAR(20));

	WHILE(@FromDate <= @ToDate)
	BEGIN
		SELECT @FromDateID = DateID
		FROM general.[Date] WHERE [Date] = @FromDate 

		CREATE TABLE Temp_RStatus(RoomID INT, ReservationID INT, RoomStatusID INT)

		INSERT INTO Temp_RStatus
		SELECT r.RoomID, ISNULL(rsh.ReservationID,R_CheckOut.ReservationID) [ReservationID]
		,CASE WHEN ISNULL(rsh.RoomStatusID,1) = 1  THEN ISNULL(R_CheckOut.RoomStatusID,ISNULL(R_Cancel.RoomStatus,1)) ELSE  rsh.RoomStatusID END [RoomStatusID]
		FROM room.Room r
		LEFT JOIN room.RoomStatusHistory rsh ON r.RoomID = rsh.RoomID AND (@FromDateID BETWEEN rsh.FromDateID AND rsh.ToDateID) 
						AND (rsh.RoomStatusID IN (1,2,4,5) AND rsh.IsPrimaryStatus = 1) AND r.LocationID = @LocationID AND r.IsActive =1 
		LEFT JOIN
		(
			SELECT rn.ReservationID, 1 as RoomStatus 
			FROM [reservation].[Reservation] rn
			WHERE ReservationStatusID = 2 AND @FromDate BETWEEN CONVERT(DATE,ExpectedCheckIn) AND CONVERT(DATE,ExpectedCheckOut) AND rn.LocationID = @LocationID
		) AS R_Cancel ON rsh.ReservationID = R_Cancel.ReservationID
		LEFT JOIN
		(						
			SELECT rm.RoomID, rn.ReservationID, 5 RoomStatusID 
			FROM [reservation].[Reservation] rn
			INNER JOIN [reservation].[ReservedRoom] rm ON rn.ReservationID = rm.ReservationID AND rm.IsActive = 1
			WHERE rn.LocationID = @LocationID AND @FromDate BETWEEN CONVERT(DATE,ISNULL(ActualCheckIn,ExpectedCheckIn)) AND CONVERT(DATE,ISNULL(ActualCheckOut,ExpectedCheckOut))
			AND rn.ReservationStatusID = 4 
		) AS R_CheckOut ON r.RoomID = R_CheckOut.RoomID
					
		INSERT INTO temp_RoomChart(RoomID, RoomNo, RoomTypeID, RoomType, [Name], [Date])
		SELECT DISTINCT rrm.RoomID, rrm.RoomNo, rrt.RoomTypeID, rrt.RoomType		
		,CASE WHEN R_Status.RoomStatusID IN (1,3) THEN 
			CASE WHEN SpecialRate.Rate IS NOT NULL THEN SpecialRate.CurrencySymbol + CAST(SpecialRate.Rate as varchar) + '?SpecialRate' 
			ELSE CASE WHEN pA1.Rate IS NULL THEN '0.00' ELSE cA1.CurrencySymbol + CAST(pA1.Rate as varchar) END END
		WHEN  R_Status.RoomStatusID = 4 THEN rs.RoomStatus 
		WHEN R_Status.RoomStatusID = 5 THEN 
			CASE WHEN Convert(date,rrn.ExpectedCheckOut) = Convert(date,@FromDate) AND rrN.ReservationStatusID != 4 THEN (Title +' '+ FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName + '?' + CAST(rrn.ReservationID AS VARCHAR) + '?Check Out?' + CAST(rrn.GuestID AS VARCHAR)  ELSE '?' + CAST(rrn.ReservationID AS VARCHAR) + '?Check Out?' + CAST(rrn.GuestID AS VARCHAR) END)
		ELSE (Title +' '+ FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName + '?' + CAST(rrn.ReservationID AS VARCHAR) + '?' + rs.RoomStatus + '?' + CAST(rrn.GuestID AS VARCHAR) ELSE '?' + CAST(rrn.ReservationID AS VARCHAR) + '?' + rs.RoomStatus + '?' + CAST(rrn.GuestID AS VARCHAR) END) END
		WHEN R_Status.RoomStatusID = 2 THEN CASE   WHEN Convert(date,rrn.ExpectedCheckIn) = Convert(date,@FromDate) THEN (Title +' '+ FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName + '?' + CAST(rrn.ReservationID AS VARCHAR) + '?Check In?' + CAST(rrn.GuestID AS VARCHAR) ELSE '?' + CAST(rrn.ReservationID AS VARCHAR) + '?Check In?' + CAST(rrn.GuestID AS VARCHAR) END)
		ELSE (Title +' '+ FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName + '?' + CAST(rrn.ReservationID AS VARCHAR) + '?' + rs.RoomStatus + '?' + CAST(rrn.GuestID AS VARCHAR) ELSE '?' + CAST(rrn.ReservationID AS VARCHAR) + '?' + rs.RoomStatus + '?' + CAST(rrn.GuestID AS VARCHAR) END) END END		 
		,FORMAT(@FromDate,'dd-MMM-yyyy') [Date] 		
		FROM  [room].[Room] rrm
		INNER JOIN [room].[RoomType] rrt ON rrm.RoomTypeID = rrt.RoomTypeID			
		LEFT JOIN [room].[Rate] r ON rrt.RoomTypeID = r.RoomTypeID AND r.IsActive = 1 AND r.IsSpecialRate = 0 AND r.LocationID = @LocationID
		LEFT JOIN currency.Price pA1 ON r.Adult1PriceID = pA1.PriceID
		LEFT JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID		
		LEFT JOIN
		(
			SELECT RoomID, ReservationID, RoomStatusID  FROM Temp_RStatus		
		) as R_Status ON rrm.RoomID = R_Status.RoomID		
		LEFT JOIN room.RoomStatus rs ON R_Status.RoomStatusID = rs.RoomStatusID
		LEFT JOIN [reservation].[Reservation] rrn ON R_Status.ReservationID = rrn.ReservationID			
		LEFT JOIN guest.vwGuestDetails ON CAST(rrn.GuestID AS VARCHAR) = guest.vwGuestDetails.GuestID
		LEFT JOIN 
		(
			SELECT rrt.RoomTypeID, CurrencySymbol, Rate FROM [room].[RoomType] rrt
			INNER JOIN [room].[Rate] rt  ON rrt.RoomTypeID = rt.RoomTypeID AND rt.IsActive = 1 AND @FromDateID  between rt.FromDateID and rt.ToDateID AND rt.LocationID = @LocationID
			LEFT JOIN currency.Price pA1 ON rt.Adult1PriceID = pA1.PriceID
			LEFT JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID
		) SpecialRate ON rrt.RoomTypeID	 = SpecialRate.RoomTypeID
		WHERE rrm.LocationID = @LocationID AND rrm.IsActive = 1

		SET @FromDate = (SELECT DATEADD(d, 1, @FromDate));
				
		DROP TABLE Temp_RStatus  
	END

	--SELECT [RoomNo], [RoomType], [Name], [Date] FROM temp_RoomChart
	SET @query = 'SELECT RoomID, RoomNo, RoomTypeID, RoomType, ' + @cols + ' from 
				  (
					SELECT	RoomID
							,RoomNo	
							,RoomTypeID
							,RoomType
							,Name						
							,[Date]															
					FROM temp_RoomChart
				  )x             
				  PIVOT 
				  (
					MAX(Name)
					for [Date] in (' + @cols + ')
				  )p              
				  WHERE RoomNo IS NOT NULL
				  ORDER BY RoomNo
				  '
    
	EXECUTE (@query)

	DROP TABLE temp_RoomChart  
END






