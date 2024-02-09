CREATE Proc [service].[usp_CarSegmentSelect]

AS
BEGIN
	--SELECT SI.[ItemID] ,SI.[Name],SI.[ItemNumber] AS AvailableQty ,SI.[Description] ,SI.[Note] ,SI.[IsAvailable],
	--(SELECT TOP 1 IP.ItemRate FROM service.ItemPrice ip WHERE ip.ItemID=[ItemID] AND ip.IsActive=1) AS ItemPrice
	--FROM [service].[Item]  SI WHERE ServiceTypeID=15 ORDER BY [ItemID]

	SELECT SI.[ItemID] ,SI.[Name],SI.[ItemNumber] AS AvailableQty ,SI.[Description] ,SI.[Note] ,SI.[IsAvailable], SP.ItemRate as ItemPrice
	FROM [service].[Item]  SI
	Left Join [service].[ItemPrice] SP on SI.ItemID = SP.ItemID and SP.IsActive = 1
	where  SI.ServiceTypeID =15
END


