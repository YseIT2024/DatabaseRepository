
CREATE PROCEDURE [service].[spAddNewItemRate]
(
	@ItemID int,	
	@PriceID int
)
AS
BEGIN
	SET NOCOUNT ON;

	INSERT INTO [service].[ItemRate]
	([ItemID], [PriceID], [IsActive], [ActivateDate])
	VALUES(@ItemID, @PriceID, 1, GETDATE())
END
