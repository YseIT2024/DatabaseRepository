
CREATE PROCEDURE [service].[spChangeItemAvailability]
(
	@ItemID int,
	@IsAvailable bit,
	@DrawerID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	IF(@IsAvailable = 1)
		BEGIN
			UPDATE [service].[Item]
			SET IsAvailable = 1			
			WHERE ItemID = @ItemID

			INSERT INTO [service].[ActivityLog]
			([ItemID],[DrawerID],[Description],[DateTime],[UserID])
			VALUES(@ItemID, @DrawerID, 'Item made available', GETDATE(), @UserID)

			SET @IsSuccess = 1;
			SET @Message = 'Item/service has been made available successfully!';
		END
	ELSE
		BEGIN
			UPDATE [service].[Item]
			SET IsAvailable = 0	
			WHERE ItemID = @ItemID

			INSERT INTO [service].[ActivityLog]
			([ItemID],[DrawerID],[Description],[DateTime],[UserID])
			VALUES(@ItemID, @DrawerID, 'Item made unavailable', GETDATE(), @UserID)

			SET @IsSuccess = 1;
			SET @Message = 'Item/service has been made unavailable successfully!';
		END

	SELECT @IsSuccess [IsSuccess], @Message [Message]	
END

