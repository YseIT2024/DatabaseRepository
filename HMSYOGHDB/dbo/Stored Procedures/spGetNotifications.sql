
CREATE PROCEDURE [dbo].[spGetNotifications]
AS
BEGIN
	SELECT NotificationID, LocationID, [DateTime] 
	FROM [dbo].[Notification]
END


