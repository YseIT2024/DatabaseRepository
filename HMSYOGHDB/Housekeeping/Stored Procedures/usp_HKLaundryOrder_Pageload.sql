
CREATE PROC [Housekeeping].[usp_HKLaundryOrder_Pageload]			
			@userId int=NULL,   
			@LocationID int=NULL
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
			
	
	---------------FOR STATUS
	 SELECT configcode AS OrderStatusCode, [ConfigValue] OrderStatusValue  FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  
	 WHERE [ConfigType] ='OS' AND  [IsActive]=1
   
   	---------------FOR Left grid Lundry Items

	SELECT LI.LaundryItemPriceID,LI.ItemID,LI.ItemRateCleaning,LI.ItemRateDryCleaning,LI.ItemRatePress,
	LI.ItemRateRepair,LI.ExpressServiceCharge,SI.Name,LI.ItemRateChild    
	FROM [HMSYOGH].[Housekeeping].[HKLaundryItemPrice] LI
	INNER JOIN [HMSYOGH].[Service].[Item] SI ON LI.ItemID=SI.ItemID
	WHERE --GETDATE() >=LI.ValidFrom
    GETDATE() BETWEEN LI.ValidFrom AND LI.ValidTo AND LI.IsActive =1 AND SI.ServiceTypeID=3 AND SI.IsAvailable=1
	ORDER BY LI.LaundryItemPriceID

	SELECT SS.TaxID,  GT.TaxRate    
	FROM [HMSYOGH].[service].[ServiceTax] SS
	INNER JOIN [HMSYOGH].[general].[Tax] GT ON SS.TaxID=GT.TaxID
	WHERE SS.IsActive=1 AND SS.ServiceTypeID=3	



  
END	



		 
