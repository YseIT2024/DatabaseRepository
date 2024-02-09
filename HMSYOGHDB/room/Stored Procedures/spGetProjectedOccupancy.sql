CREATE Proc [room].[spGetProjectedOccupancy]-- '2013/03/01','2013/03/10'
(	
	@LocationID int =null,	
	@UserID int = null,
	@SubCategoryId int =null,
	@FromDate date,
	@ToDate date
)
AS
BEGIN	
	
	DECLARE @INTDAY int;	
	--DECLARE @tempOccupancy table (ID int identity(1,1),startdate date)
	DECLARE @tempDate table (ID int identity(1,1),startdate date);

	SELECT @INTDAY=DATEDIFF(DAY,@FromDate,@ToDate);

	WHILE @INTDAY >=0 
		BEGIN
		INSERT INTO @tempDate (startdate) VALUES(@FromDate)
		set @INTDAY=@INTDAY-1
		set @FromDate=DATEADD(day,1,@FromDate)
	
		END

	SELECT tt.startdate,
		(SELECT CONCAT('INV=7, OC=', COUNT(RRD.Rooms))  FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=39 AND RRD.NightDate=tt.startdate) AS A39,	
		(SELECT CONCAT('INV=2, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=40 AND RRD.NightDate=tt.startdate) AS A40,
		(SELECT CONCAT('INV=9, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=41 AND RRD.NightDate=tt.startdate) AS A41,
		(SELECT CONCAT('INV=23, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=42 AND RRD.NightDate=tt.startdate) AS A42,
		(SELECT CONCAT('INV=2, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=43 AND RRD.NightDate=tt.startdate) AS A43,
		(SELECT CONCAT('INV=31, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=44 AND RRD.NightDate=tt.startdate) AS A44,
		(SELECT CONCAT('INV=4, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=45 AND RRD.NightDate=tt.startdate) AS A45,
		(SELECT CONCAT('INV=10, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=46 AND RRD.NightDate=tt.startdate) AS A46,
		(SELECT CONCAT('INV=14, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=47 AND RRD.NightDate=tt.startdate) AS A47,
		(SELECT CONCAT('INV=1, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=48 AND RRD.NightDate=tt.startdate) AS A48,
		(SELECT CONCAT('INV=1, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=49 AND RRD.NightDate=tt.startdate) AS A49,
		(SELECT CONCAT('INV=104, OC=', COUNT(RRD.Rooms)) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=49 AND RRD.NightDate=tt.startdate) AS TOTAL,
		(SELECT COUNT(RRD.Rooms) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=49 AND RRD.NightDate=tt.startdate) AS ECI,
		(SELECT COUNT(RRD.Rooms) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
					INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
					WHERE PIT.SubCategoryID=49 AND RRD.NightDate=tt.startdate) AS ECO

	from @tempDate tt


	--WHILE @ToDate-@FromDate >0 
	--	BEGIN			
	--		select @FromDate,						
	--			(SELECT COUNT(RRD.Rooms) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
	--				INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
	--				WHERE PIT.SubCategoryID=39 AND RRD.NightDate=@FromDate) AS A39,  
	--			(SELECT COUNT(RRD.Rooms) FROM [HMSYOGH].[reservation].[ReservationDetails] RRD 
	--				INNER JOIN Products.Item PIT ON RRD.ItemID=PIT.ItemID 
	--				WHERE PIT.SubCategoryID=40 AND RRD.NightDate=@FromDate) AS A40 	
					
	--	set @FromDate=@FromDate+1
	--	END
END


