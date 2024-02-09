
CREATE PROC [Housekeeping].[usp_HKMiniBarItemOrderconsumption_Pageload]
			@FolioNumber int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
			
	


	SELECT HKM.OrdereDate, HKM.RoomNo,HKM.OrderStatus,HKM.FolioNumber,HKM.IsActive,HKM.Discount,HKM.GuestID,HKM.PrintStatus,HKM.OrderId
	FROM [Housekeeping].[HKMinibarOrder] HKM
	where HKM.FolioNumber=@FolioNumber

	--SELECT SI.Name,SST.ItemRate,SST.ValidFrom,SST.ValidTo,SST.Discount
	--FROM [service].[Item] SI
	--INNER JOIN [service].[ItemPrice] SST ON SI.ItemID= SST.ItemID
	--Where SI.ServiceTypeID=@ServiceTypeID 
	--order by SI.ItemID
	--Select * from [service].[ItemPrice]
	--Select * from [Housekeeping].[HKMinibarOrder]
	--Select * from [service].[Item]
	--Select * from [service].[ServiceTax]

END	



		 
