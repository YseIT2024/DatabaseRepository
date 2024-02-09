
CREATE PROCEDURE [dbo].[spUpdateNotificationStatus]
(
	@LocationID int,
	@UserID int,
	@NotificationID int
)
AS
BEGIN
	DECLARE @Success bit = 0;

	IF NOT EXISTS(SELECT ID FROM dbo.NotificationAndUser WHERE NotificationID = @NotificationID AND LocationID = @LocationID AND UserID = @UserID AND HasSeen = 1)
	BEGIN
		INSERT INTO [dbo].[NotificationAndUser]
		([LocationID],[NotificationID],[UserID],[HasSeen],[DateTime])
		VALUES(@LocationID, @NotificationID, @UserID, 1, GETDATE())

		SET @Success = 1;
	END

	SELECT @Success [IsSuccess]
END


