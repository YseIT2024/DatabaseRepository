
CREATE PROCEDURE [service].[spActivateDeactivateRate]
(
	@ItemRateID int,
	@IsActivate bit,
	@DrawerID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Status int = 0;
	DECLARE @Message varchar(250) = '';
	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	IF(@IsActivate = 1)
		BEGIN
			UPDATE service.ItemRate
			SET IsActive = 1
			,ActivateDate = GETDATE()
			WHERE ItemRateID = @ItemRateID

			INSERT INTO [service].[ActivityLog]
			([ItemRateID],[DrawerID],[Description],[DateTime],[UserID])
			VALUES(@ItemRateID, @DrawerID, 'Activated rate', GETDATE(), @UserID)

			SET @Status = 1;
			SET @Message = 'The rate has been activated successfully.';
		END
	ELSE
		BEGIN
			UPDATE service.ItemRate
			SET IsActive = 0
			,DeactivateDate = GETDATE()
			WHERE ItemRateID = @ItemRateID

			INSERT INTO [service].[ActivityLog]
			([ItemRateID],[DrawerID],[Description],[DateTime],[UserID])
			VALUES(@ItemRateID, @DrawerID, 'Deactivated rate', GETDATE(), @UserID)

			SET @Status = 1;
			SET @Message = 'The rate has been deactivated successfully.';
		END

	SELECT @Status [Status], @Message [Message]	
END

