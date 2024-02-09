
CREATE PROC [Housekeeping].[usp_HKLaundryItempriceList_Select]			
	
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	
			
		  SELECT  LP.[ItemID],SI.[Name],LP.[ItemRateCleaning],LP.[ItemRateDryCleaning],LP.[ItemRatePress]
		    ,LP.[ItemRateRepair],LP.[ItemRateChild],LP.[ExpressServiceCharge],SI.[Description],LP.[ValidFrom],LP.[ValidTo],LP.IsActive
		  FROM [HMSYOGH].[Housekeeping].[HKLaundryItemPrice] LP
		  INNER JOIN [service].[Item] SI on SI.ItemID=LP.ItemID
		 WHERE ServiceTypeID = 3
		 order by ItemID DESC   --------Added by sravani ------------
		  
END
