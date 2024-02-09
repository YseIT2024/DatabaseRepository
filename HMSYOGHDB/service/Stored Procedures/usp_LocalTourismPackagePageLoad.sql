CREATE PROCEDURE [service].[usp_LocalTourismPackagePageLoad]
(
@ServiceTypeID int=Null,
@UserId int=Null
)

AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(200) = '';
	DECLARE @PriceID int;
	--DECLARE @ItemNumber int;	
	
	IF @ServiceTypeID IS NULL 
		SET @ServiceTypeID=16;

	SELECT [ItemID] ,[Name] FROM [HMSYOGH].[service].[Item]  WHERE [ServiceTypeID]=15 AND  IsAvailable=1 --TO GET CAR SEGMENT

	SELECT [ItemID] ,[Name] FROM [HMSYOGH].[service].[Item]  WHERE [ServiceTypeID]=1 AND  IsAvailable=1 --TO GET COMPLEMENTARY SERVICES TO BIND FOR COMPLEMENTARY SERVICE

	SELECT SI.ItemID, SI.[Name], SI.[ItemNumber], SI.[Description], SI.[Note], SI.[LocationID], SI.[IsAvailable],SIP.ItemRate, SIP.Discount,SIP.ValidFrom,SIP.ValidTo
	FROM [service].[Item] SI
	INNER JOIN [service].[ItemPrice] SIP ON SI.ItemID=SIP.ItemID 
	WHERE SI.ServiceTypeID= @ServiceTypeID
	ORDER BY  SI.ItemID DESC
	--TO GET PACKAGE DETAILS FOR BINDING IN GRID

	-------------- Begin To Get Mapped CarSegment Data -------------------
	SELECT [TourPackageServiceID],[CarServiceID] FROM [service].[TourPackageCarMapping]	
	----------------End To Get Mapped CarSegment Data---------------------

	------------Begin To Get Mapped ComplementaryServic Data -------------------
				
	SELECT  [TourPackageServiceID],[ComplimentaryServiceID] FROM [service].[TourPackageServiceMapping]					   						   

	----------------End To Get Mapped ComplementaryServic Data--------------------

END




