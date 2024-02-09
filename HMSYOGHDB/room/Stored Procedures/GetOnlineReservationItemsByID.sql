

CREATE Proc [room].[GetOnlineReservationItemsByID]
(
	@OnlineReservedItems AS [room].[OnlineReservedItems] READONLY
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	
		SET NOCOUNT ON;
	
	SELECT [ItemID],[ItemName] 
    FROM  [Products].[Item] where  [ItemID] in( select [ItemID] from @OnlineReservedItems)

  
END

