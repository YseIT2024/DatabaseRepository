
CREATE Proc [service].[GetCarSegmentCost]
(
	@DrawerID int,
	@LocationID int,
	@CarSegmentID int 
)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @BaseCarSegmentId as int
	DECLARE @BaseCarSegmentRate as decimal
	
	
	SELECT @BaseCarSegmentId=ItemId FROM [service].[Item] WHERE  [name] LIKE 'MINI%'
	SELECT @BaseCarSegmentRate=[ItemRate] FROM [service].[ItemPrice] WHERE  [ItemID]=@BaseCarSegmentId

	--Get Tourism Packages
	SELECT ItemId, [ItemRate]-@BaseCarSegmentRate as CarSegmentRate  FROM [service].[ItemPrice] WHERE [ItemID] = @CarSegmentID AND IsActive=1 	
	
	
END




