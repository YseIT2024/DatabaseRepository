
CREATE  PROCEDURE [report].[spGetRoomChart_New]-- '07-18-2022','08-26-2022',1,1
(
	@FromDate date,
	@ToDate date,
	@LocationID int,
	@RateTypeId int
)
as
BEGIN	
	--SET NOCOUNT ON;

declare @FromDate1 date = @FromDate
declare @ToDate1 date = @ToDate
declare @LocationID1 int = @LocationID
declare @RateTypeId1 int = @RateTypeId


 

	
	DECLARE @FromDateID int = (SELECT CAST(FORMAT(@FromDate1,'yyyyMMdd') as int));
	DECLARE @ToDateID int = (SELECT CAST(FORMAT(@ToDate1,'yyyyMMdd') as int));
	DECLARE @cols as NVARCHAR(MAX);
	DECLARE @query  as NVARCHAR(MAX);
	
	DECLARE @T1 TIME = '00:00'; -- First Half Start Time
	DECLARE @T2 TIME = '12:00'; -- First Half End Time
	DECLARE @T3 TIME = '12:00'; -- Second Half Start Time
	DECLARE @T4 TIME = '23:59'; -- Second Half End Time	

	DECLARE @DateTable TABLE(DateID INT, [DATE] VARCHAR(30))	
	
	INSERT INTO @DateTable(DateID, [DATE])
	(
		SELECT DateID, FORMAT([Date],'dd-MMM-yyyy 00:00 - 12:00') [Date]  
		FROM [general].[Date] 
		WHERE DateID BETWEEN @FromDateID AND @ToDateID

		UNION 

		SELECT DateID, FORMAT([Date],'dd-MMM-yyyy 14:00 - 23:59') [Date]  
		FROM [general].[Date] 
		WHERE DateID BETWEEN @FromDateID AND @ToDateID
	)

	SELECT @cols = COALESCE(@cols + ',','') + QUOTENAME([DATE])
	FROM @DateTable	
	
	--IF (EXISTS (SELECT TOP 1 * 
 --                FROM INFORMATION_SCHEMA.TABLES 
 --                WHERE TABLE_SCHEMA = 'dbo' 
 --                AND  TABLE_NAME = 'temp_Chart'))
	--BEGIN
	--	DROP TABLE temp_Chart;
	--END	

	IF OBJECT_ID('tempdb..#temp_Chart') IS NOT NULL DROP TABLE #temp_Chart

	CREATE TABLE #temp_Chart(RoomID int, RoomNo int, RoomTypeID int, RoomType varchar(5), [Name] varchar(100), [Date] varchar(25));	

	--drop table temp_Chart

	DECLARE @Count INT = 2  -- one day has divided into two parts @Init = 1 => First half (check out), @Init = 2 => Second half (check in)
	DECLARE @Init INT = 1
	
	WHILE(@FromDate1 <= @ToDate1)
	BEGIN
		SELECT @FromDateID = DateID
		FROM general.[Date] 
		WHERE [Date] = @FromDate1		
		
		---- RoomStatusID 1 ->	Vacant
		---- RoomStatusID 2 ->	Reserved
		---- RoomStatusID 3 ->	House Keeping
		---- RoomStatusID 4 ->	Out Of Order
		---- RoomStatusID 5 ->	In House
		---- RoomStatusID 8 ->	Checked Out

		----rs_2 => Room StatusID 2 & Reserved
		----rs_02 => Room StatusID 2 &  checkin		
		----rs_5 => Room StatusID 5 & In House
		----rs_005 => Room StatusID 5 & Checked In
		----rs_05 => Room StatusID 5 & today checkout
		----rs_8 => Room StatusID 8
		----rs_10 => Room Change
	
		WHILE (@Init <= @Count)
		BEGIN
			INSERT INTO #temp_Chart(RoomID, RoomNo, RoomTypeID, RoomType, [Date], [Name])
			(
			SELECT DISTINCT r.RoomID, r.RoomNo, rt.RoomTypeID, rt.RoomType,	CASE WHEN @Init = 1 THEN FORMAT(@FromDate1,'dd-MMM-yyyy 00:00 - 12:00') ELSE FORMAT(@FromDate1,'dd-MMM-yyyy 14:00 - 23:59') END as [Date]
			,CASE WHEN rs_detail.RoomStatusID = 2  /*Reserved*/ THEN 
			(
				CASE WHEN @Init = 1 AND CONVERT(date,rs_detail.ExpectedCheckIn) < CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?' + CASE WHEN CONVERT(date,rs_detail.ExpectedCheckOut) = CONVERT(date,@FromDate1) THEN 'rs2_05' ELSE 'rs_2' END  /*Todaycheckout for reserved*/
						+ '?' + CAST(rs_detail.GuestID as varchar)
						+ '?' +  CASE WHEN 
										(SELECT ISNULL(SUM(Amount),0) FROM guest.GuestWallet WHERE ReservationID = rs_detail.ReservationID 
										AND AccountTypeID = 23) > 0 THEN 'ad_pay' ELSE 'n_pay' END
					WHEN @Init = 2 AND CONVERT(date,rs_detail.ExpectedCheckIn) = CONVERT(date,@FromDate1)    THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?' + CASE WHEN CONVERT(date,rs_detail.ExpectedCheckIn) <= CONVERT(date,@FromDate1) /*Todaycheckin*/ THEN 'rs_02' ELSE 'rs_2' END
						+ '?' + CAST(rs_detail.GuestID as varchar)
						+ '?' +  CASE WHEN 
										(SELECT ISNULL(SUM(Amount),0) FROM guest.GuestWallet WHERE ReservationID = rs_detail.ReservationID 
										AND AccountTypeID = 23) > 0 THEN 'ad_pay' ELSE 'n_pay' END
					WHEN @Init = 2 AND CONVERT(date,rs_detail.ExpectedCheckOut) > CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?rs_2'
						+ '?' + CAST(rs_detail.GuestID as varchar)
						+ '?' +  CASE WHEN 
										(SELECT ISNULL(SUM(Amount),0) FROM guest.GuestWallet WHERE ReservationID = rs_detail.ReservationID 
										AND AccountTypeID = 23) > 0 THEN 'ad_pay' ELSE 'n_pay' END
					ELSE
						CASE WHEN filter_rate.Rate IS NULL THEN 'n.a.' ELSE filter_rate.CurrencySymbol + ' ' + CAST(filter_rate.Rate as varchar) END
					END	
			)				
			WHEN rs_detail.RoomStatusID = 4 /*Out Of Order*/ THEN			
			(
				CASE WHEN @Init = 1 AND Convert(date, FromDate) = @FromDate1 and (cast(FromDate as time(0)) BETWEEN @T1 AND @T2)	THEN 
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)
					WHEN @Init = 2 AND Convert(date, FromDate) = @FromDate1 and (cast(FromDate as time(0)) BETWEEN @T3 AND @T4) THEN
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)
					WHEN @Init = 1 AND Convert(date, ToDate) = @FromDate1 and (cast(ToDate as time(0)) BETWEEN @T1 AND @T2)	THEN 
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)
					WHEN @Init = 2 AND Convert(date, ToDate) = @FromDate1 and (cast(ToDate as time(0)) BETWEEN @T3 AND @T4) THEN
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)					
					WHEN Convert(date,FromDate) < @FromDate1 AND Convert(date,ToDate) > @FromDate1 THEN 
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)	
					WHEN @Init = 2 AND Convert(date, FromDate) = @FromDate1  AND  cast(FromDate as time(0)) < @T3   THEN
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)
					WHEN @Init = 1 AND Convert(date, ToDate) = @FromDate1  AND  cast(ToDate as time(0)) > @T3 AND (SELECT DATEDIFF(DAY, Convert(date, FromDate),  Convert(date, ToDate))) > 0   THEN
						rs_detail.RoomStatus 
						+ '?' + CAST(rs_detail.RSHistoryID as varchar)
					ELSE
						CASE WHEN filter_rate.Rate IS NULL THEN 'n.a.' ELSE filter_rate.CurrencySymbol + ' ' + CAST(filter_rate.Rate as varchar) END
					END   
			)
			WHEN rs_detail.RoomStatusID = 5 /*In House*/ THEN 
			(
				CASE WHEN @Init = 1 AND CONVERT(date,rs_detail.ExpectedCheckOut) = CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?' + CASE WHEN CONVERT(date,rs_detail.ExpectedCheckOut) = CONVERT(date,@FromDate1) AND rs_detail.ReservationStatusID != 4 /*Todaycheckout*/ THEN 'rs_05' ELSE 'rs_5' END
						+ '?' + CAST(rs_detail.GuestID as varchar)					
					WHEN @Init = 2 AND CONVERT(date,FromDate) = CONVERT(date,@FromDate1) AND CONVERT(date,rs_detail.ActualCheckIn) <> CONVERT(date,FromDate)  THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?rs_10'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN @Init = 2 AND  CONVERT(date,rs_detail.ActualCheckIn) = CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar)
						+ '?rs_005'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN  CONVERT(date,FromDate) < CONVERT(date,@FromDate1) AND CONVERT(date,@FromDate1) > CONVERT(date,rs_detail.ActualCheckIn) AND CONVERT(date,@FromDate1) < CONVERT(date,rs_detail.ExpectedCheckOut)  THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_5'
						+ '?' + CAST(rs_detail.GuestID as varchar)						
					ELSE
						CASE WHEN filter_rate.Rate IS NULL THEN 'n.a.' ELSE filter_rate.CurrencySymbol + ' ' + CAST(filter_rate.Rate as varchar) END
					END
			)
			WHEN rs_detail.RoomStatusID = 8 /*Checked Out*/ THEN 
			(
				CASE WHEN @Init = 1 AND CONVERT(date,rs_detail.ActualCheckOut) = CONVERT(date,@FromDate1) AND CONVERT(date,rs_detail.ActualCheckIn) < CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_8'
						+ '?' + CAST(rs_detail.GuestID as varchar)						
					WHEN @Init = 2 AND CONVERT(date,rs_detail.ActualCheckIn) = CONVERT(date,@FromDate1) AND CONVERT(date,rs_detail.ActualCheckOut) = CONVERT(date,@FromDate1) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_8'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					--WHEN @Init = 2 AND CONVERT(date,FromDate) = CONVERT(date,@FromDate) and CONVERT(date,ToDate) =  CONVERT(date,FromDate) and  CONVERT(date,ISNULL(rs_detail.ActualCheckOut, rs_detail.ExpectedCheckOut)) <> CONVERT(date,ToDate) THEN
					--	rs_detail.FullName 
					--	+ '?' + CAST(rs_detail.ReservationID as varchar) 
					--	+ '?rs_10'
					--	+ '?' + CAST(rs_detail.GuestID as varchar)
					--WHEN @Init = 2 AND CONVERT(date,rs_detail.ActualCheckIn) = CONVERT(date,@FromDate) AND CONVERT(date,rs_detail.ActualCheckIn) = CONVERT(date,FromDate) AND CONVERT(date,ISNULL(rs_detail.ActualCheckOut, rs_detail.ExpectedCheckOut)) = CONVERT(date,ToDate)  THEN
					--	rs_detail.FullName 
					--	+ '?' + CAST(rs_detail.ReservationID as varchar) 
					--	+ '?rs_10'
					--	+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN @Init = 2 AND CONVERT(date,rs_detail.ActualCheckIn) = CONVERT(date,@FromDate1) and CONVERT(date,rs_detail.ActualCheckIn) =  CONVERT(date,FromDate) AND CONVERT(date,FromDate) <> CONVERT(date,ToDate)  THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_005'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN @Init = 1 AND CONVERT(date,@FromDate1) <>  CONVERT(date,FromDate) AND CONVERT(date,@FromDate1) =  CONVERT(date,ToDate) 
					AND (CASE WHEN rs_detail.ActualCheckOut IS NULL THEN  CONVERT(date,rs_detail.ExpectedCheckOut) ELSE CONVERT(date,rs_detail.ActualCheckOut) END) > CONVERT(date,ToDate) THEN						
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_10'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN @Init = 2 AND CONVERT(date,@FromDate1) =  CONVERT(date,FromDate) AND CONVERT(date,rs_detail.ActualCheckIn) < CONVERT(date,FromDate)  THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_10'
						+ '?' + CAST(rs_detail.GuestID as varchar)
					WHEN  (@Init = 2 OR CONVERT(date,@FromDate1) >  CONVERT(date,FromDate)) AND (CONVERT(date,rs_detail.ActualCheckIn) < CONVERT(date,@FromDate1) AND  CONVERT(date,@FromDate1) <>  CONVERT(date,ToDate)) THEN
						rs_detail.FullName 
						+ '?' + CAST(rs_detail.ReservationID as varchar) 
						+ '?rs_5'
						+ '?' + CAST(rs_detail.GuestID as varchar)											
					ELSE
						CASE WHEN filter_rate.Rate IS NULL THEN 'n.a.' ELSE filter_rate.CurrencySymbol + ' ' + CAST(filter_rate.Rate as varchar) END						
					END
			)
			ELSE 
			(				
				CASE WHEN filter_rate.Rate IS NULL THEN 'n.a.' ELSE filter_rate.CurrencySymbol + ' ' + CAST(filter_rate.Rate as varchar) END
			)END as [Name]	
			FROM  [room].[Room] r
			INNER JOIN [room].[RoomType] rt ON r.RoomTypeID = rt.RoomTypeID			
			LEFT JOIN 
			(
				SELECT rat1.[RoomTypeID], [Rate], [CurrencySymbol]
				FROM [room].[Rate] rat1
				INNER JOIN
				(
					SELECT MAX(RateID) as RateID, [RoomTypeID]
					FROM [room].[Rate]
					WHERE IsActive = 1 AND LocationID = @LocationID1 AND DurationID = @RateTypeId1 AND CONVERT(DATE, ActivationDate) <= @FromDate1
					GROUP BY [RoomTypeID]						
				) as rat2 ON rat1.RateID = rat2.RateID
				INNER JOIN currency.Price pA1 ON rat1.Adult1PriceID = pA1.PriceID
				INNER JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID					
			) filter_rate ON rt.RoomTypeID = filter_rate.RoomTypeID			
			LEFT JOIN
			(
				SELECT trs.RoomID, trs.ReservationID, trs.RoomStatusID, rs.RoomStatus, rd.FullName, ExpectedCheckOut, ReservationStatusID, ExpectedCheckIn, GuestID, ActualCheckIn, ActualCheckOut, FromDate, ToDate, RSHistoryID 
				FROM
				(
					SELECT r.RoomID, ISNULL(rsh.ReservationID,r_checkedout.ReservationID) as ReservationID, COALESCE(rsh.RoomStatusID,r_checkedout.RoomStatusID,1) as RoomStatusID, rsh.FromDate, rsh.ToDate, rsh.RSHistoryID
					FROM room.Room r
					LEFT JOIN room.RoomStatusHistory rsh ON r.RoomID = rsh.RoomID AND @FromDateID BETWEEN rsh.FromDateID AND rsh.ToDateID AND rsh.RoomStatusID IN (2,4,5,8)	
					LEFT JOIN
					(						
						SELECT rm.RoomID, rn.ReservationID, 8 as [RoomStatusID] -- 8 for checked out
						FROM [reservation].[Reservation] rn
						INNER JOIN [reservation].[ReservedRoom] rm ON rn.ReservationID = rm.ReservationID AND rm.IsActive = 1
						WHERE rn.LocationID = @LocationID1 AND rn.ReservationStatusID = 4
						AND @FromDate1 BETWEEN CONVERT(DATE,ISNULL(ActualCheckIn,ExpectedCheckIn)) AND (CONVERT(DATE,ISNULL(ActualCheckOut,ExpectedCheckOut)))		
					) AS r_checkedout ON r.RoomID = r_checkedout.RoomID
					WHERE r.LocationID = @LocationID1 AND r.IsActive = 1
				) trs
				INNER JOIN room.RoomStatus rs ON trs.RoomStatusID = rs.RoomStatusID
				LEFT JOIN
				(
					SELECT DISTINCT r.[ReservationID], r.[ExpectedCheckIn], r.[ExpectedCheckOut], r.ReservationStatusID, r.GuestID,
					([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName], r.ActualCheckIn, r.ActualCheckOut
					FROM [reservation].[Reservation] r
					INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
					INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
					INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
				) as rd ON trs.ReservationID = rd.ReservationID
			) as rs_detail ON r.RoomID = rs_detail.RoomID		
			WHERE r.LocationID = @LocationID1 AND r.IsActive = 1
		) 

			SET @Init = @Init + 1
		END		

		SET @FromDate1 = (SELECT DATEADD(d, 1, @FromDate1));
		
		SET @Init = 1
	END

	--SELECT * FROM temp_Chart
	SET @query = 'SELECT RoomID, RoomNo, RoomTypeID, RoomType, ' + @cols + 
				'from 
				  (
					SELECT RoomID, RoomNo, RoomTypeID, RoomType, Name, [Date]											
					FROM #temp_Chart
				  )x    
				  PIVOT
				  (
					MAX(Name)
					for [Date] in (' + @cols + ')
				  )p
				  WHERE RoomNo IS NOT NULL
				  ORDER BY RoomNo
				  '
    
	EXECUTE (@query);

	DROP TABLE #temp_Chart;
END
