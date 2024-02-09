create FUNCTION [reservation].[fnGetMiniBarItemName] 
(	
	@ServiceTypeId int	
)
RETURNS varchar(MAX)
AS	
BEGIN
	DECLARE @strMiniBarItemName VARCHAR(255);

	SELECT @strMiniBarItemName = COALESCE(@strMiniBarItemName + ',', '') + si.Name
	FROM [service].[Item] si
	WHERE si.ItemID IN (
		SELECT DISTINCT si.ItemId
		FROM [Housekeeping].[HKMinibarOrderDetails] HMO
		INNER JOIN [service].[Item] si ON HMO.ItemId = si.ItemID
		WHERE HMO.OrderId = @ServiceTypeId
	);

RETURN @strMiniBarItemName;
END