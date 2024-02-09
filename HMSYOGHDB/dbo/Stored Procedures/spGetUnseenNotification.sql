
CREATE PROCEDURE [dbo].[spGetUnseenNotification]
(
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SELECT COUNT(n.NotificationID) Notifications	
	FROM [dbo].[Notification] n
	LEFT JOIN [dbo].[NotificationAndUser] nu ON n.NotificationID = nu.NotificationID AND nu.UserID = @UserID AND nu.LocationID = @LocationID
	WHERE n.LocationID = @LocationID AND nu.NotificationID IS NULL
END


