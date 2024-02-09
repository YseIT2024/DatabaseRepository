
CREATE PROCEDURE [report].[spGetRoomChart] --'06-01-2020','06-30-2020',1,1
(
	@FromDate date,
	@ToDate date,
	@LocationID int,
	@RateTypeId int
)
as
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @FromDateID int = (SELECT CAST(FORMAT(@FromDate,'yyyyMMdd') as int));
	DECLARE @ToDateID int = (SELECT CAST(FORMAT(@ToDate,'yyyyMMdd') as int));
	DECLARE @cols as NVARCHAR(MAX);
	DECLARE @query  as NVARCHAR(MAX);

	SELECT @cols = COALESCE(@cols + ',','') + QUOTENAME([DATE])
	FROM 
	(
		SELECT FORMAT([Date],'dd-MMM-yyyy') [Date]  
		FROM [general].[Date] 
		WHERE DateID BETWEEN @FromDateID AND @ToDateID
	) as tab;

	CREATE TABLE temp_Chart(RoomID int, RoomNo int, RoomTypeID int, RoomType varchar(5), [Name] varchar(100), [Date] varchar(12));	

	WHILE(@FromDate <= @ToDate)
	BEGIN
		SELECT @FromDateID = DateID
		FROM general.[Date] 
		WHERE [Date] = @FromDate		
		
		---- RoomStatusID 1 ->	Vacant
		---- RoomStatusID 2 ->	Reserved
		---- RoomStatusID 3 ->	House Keeping
		---- RoomStatusID 4 ->	Out Of Order
		---- RoomStatusID 5 ->	In House
		---- RoomStatusID 8 ->	Checked Out

		----rs_2 => Room StatusID 2 & Reserved
		----rs_02 => Room StatusID 2 & today checkin
		----rs_5 => Room StatusID 5 & In House
		----rs_05 => Room StatusID 5 & today checkout
		----rs_8 => Room StatusID 8
		
		INSERT INTO temp_Chart(RoomID, RoomNo, RoomTypeID, RoomType, [Date], [Name])
		(
			SELECT DISTINCT r.RoomID, r.RoomNo, rt.RoomTypeID, rt.RoomType,	FORMAT(@FromDate,'dd-MMM-yyyy') as [Date]
			,CASE WHEN rs_detail.RoomStatusID = 2 /*Reserved*/ THEN 
			(
				rs_detail.FullName 
				+ '?' + CAST(rs_detail.ReservationID as varchar)
				+ '?' + CASE WHEN CONVERT(date,rs_detail.ExpectedCheckIn) = CONVERT(date,@FromDate) /*Todaycheckin*/ THEN 'rs_02' ELSE 'rs_2' END
				+ '?' + CAST(rs_detail.GuestID as varchar)
				+  '?' +  CASE WHEN 
								(SELECT ISNULL(SUM(Amount),0) FROM guest.GuestWallet WHERE ReservationID = rs_detail.ReservationID 
								AND AccountTypeID = 23) > 0 THEN 'ad_pay' ELSE 'n_pay' END
			)
			WHEN rs_detail.RoomStatusID = 4 /*Out Of Order*/ THEN (rs_detail.RoomStatus)	
			WHEN rs_detail.RoomStatusID = 5 /*In House*/ THEN 
			(
				rs_detail.FullName 
				+ '?' + CAST(rs_detail.ReservationID as varchar)
				+ '?' + CASE WHEN CONVERT(date,rs_detail.ExpectedCheckOut) = CONVERT(date,@FromDate) AND rs_detail.ReservationStatusID != 4 /*Todaycheckout*/ THEN 'rs_05' ELSE 'rs_5' END
				+ '?' + CAST(rs_detail.GuestID as varchar)
			)
			WHEN rs_detail.RoomStatusID = 8 /*Checked Out*/ THEN 
			(
				rs_detail.FullName 
				+ '?' + CAST(rs_detail.ReservationID as varchar) 
				+ '?rs_8'
				+ '?' + CAST(rs_detail.GuestID as varchar)
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
					WHERE IsActive = 1 AND LocationID = @LocationID AND DurationID = @RateTypeId
					GROUP BY [RoomTypeID]
				) as rat2 ON rat1.RateID = rat2.RateID
				INNER JOIN currency.Price pA1 ON rat1.Adult1PriceID = pA1.PriceID
				INNER JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID
			) filter_rate ON rt.RoomTypeID = filter_rate.RoomTypeID			
			LEFT JOIN
			(
				SELECT trs.RoomID, trs.ReservationID, trs.RoomStatusID, rs.RoomStatus, rd.FullName, ExpectedCheckOut, ReservationStatusID, ExpectedCheckIn, GuestID
				FROM
				(
					SELECT r.RoomID, ISNULL(rsh.ReservationID,r_checkedout.ReservationID) as ReservationID, COALESCE(rsh.RoomStatusID,r_checkedout.RoomStatusID,1) as RoomStatusID
					FROM room.Room r
					LEFT JOIN room.RoomStatusHistory rsh ON r.RoomID = rsh.RoomID AND @FromDateID BETWEEN rsh.FromDateID AND rsh.ToDateID AND rsh.RoomStatusID IN (2,4,5,8)	
					LEFT JOIN
					(						
						SELECT rm.RoomID, rn.ReservationID, 8 as [RoomStatusID] -- 8 for checked out
						FROM [reservation].[Reservation] rn
						INNER JOIN [reservation].[ReservedRoom] rm ON rn.ReservationID = rm.ReservationID AND rm.IsActive = 1
						WHERE rn.LocationID = @LocationID AND rn.ReservationStatusID = 4
						AND @FromDate BETWEEN CONVERT(DATE,ISNULL(ActualCheckIn,ExpectedCheckIn)) AND (CONVERT(DATE,ISNULL(ActualCheckOut,ExpectedCheckOut)))		
					) AS r_checkedout ON r.RoomID = r_checkedout.RoomID
					WHERE r.LocationID = @LocationID AND r.IsActive = 1
				) trs
				INNER JOIN room.RoomStatus rs ON trs.RoomStatusID = rs.RoomStatusID
				LEFT JOIN
				(
					SELECT DISTINCT r.[ReservationID], r.[ExpectedCheckIn], r.[ExpectedCheckOut], r.ReservationStatusID, r.GuestID,
					([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]
					FROM [reservation].[Reservation] r
					INNER JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
					INNER JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
					INNER JOIN [person].[Title] t ON cd.TitleID = t.TitleID
				) as rd ON trs.ReservationID = rd.ReservationID
			) as rs_detail ON r.RoomID = rs_detail.RoomID		
			WHERE r.LocationID = @LocationID AND r.IsActive = 1
		) 

		SET @FromDate = (SELECT DATEADD(d, 1, @FromDate));
	END

	--SELECT * FROM temp_Chart
	SET @query = 'SELECT RoomID, RoomNo, RoomTypeID, RoomType, ' + @cols + 
				'from 
				  (
					SELECT RoomID, RoomNo, RoomTypeID, RoomType, Name, [Date]											
					FROM temp_Chart
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

	DROP TABLE temp_Chart;
END

