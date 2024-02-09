CREATE PROC [Housekeeping].[usp_HKMiniBarItem_Pageload] 
			@ServiceTypeID int =null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
			

	SELECT SI.ItemID, SI.Name,SIP.ItemRate,SIP.ValidFrom,SIP.ValidTo,SI.Description,SI.UOMID,SIP.CreatedOn,SI.IsAvailable
	FROM [service].[Item] SI
	INNER JOIN [service].[ItemPrice] SIP ON SI.ItemID=SIP.ItemID
	Where SI.ServiceTypeID=@ServiceTypeID And Sip.IsActive=1
	order by SI.ItemID DESC

END	



		 
