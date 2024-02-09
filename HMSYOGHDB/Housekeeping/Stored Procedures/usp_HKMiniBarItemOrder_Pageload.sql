
CREATE PROC [Housekeeping].[usp_HKMiniBarItemOrder_Pageload] 
			@ServiceTypeID int 
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
			
	
	---------------FOR STATUS
	-- SELECT configcode AS OrderStatusCode, [ConfigValue] OrderStatusValue  FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='OS' AND  [IsActive]=1
   
   	---------------FOR Left grid Lundry Items

	SELECT SI.ItemID, SI.Name,SIP.ItemRate,SI.UOMID,SST.TaxID,GT.TaxRate
	FROM [service].[Item] SI
	INNER JOIN [service].[ItemPrice] SIP ON SI.ItemID=SIP.ItemID
	INNER JOIN [service].[ServiceTax] SST ON SI.ServiceTypeID= SST.ServiceTypeID
	INNER JOIN [general].[Tax] GT ON SST.TaxID=GT.TaxID
	WHERE SI.ServiceTypeID=  @ServiceTypeID And SIP.IsActive=1
	order by SI.ItemID 

	---SELECT OrderId,ItemId,Rate FROM [Housekeeping].[HKMinibarOrderDetails]
END	

