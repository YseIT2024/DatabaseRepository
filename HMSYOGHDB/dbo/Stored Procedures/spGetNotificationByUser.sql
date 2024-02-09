
CREATE PROCEDURE [dbo].[spGetNotificationByUser] --1,1,0,0,1
(
	@LocationID int,
	@UserID int,
	@MinID int,
	@MaxID int,
	@IsNewer bit
)
AS
BEGIN
	DECLARE @Rows int = 10;

	IF(@MaxID = 0) --First Time
		BEGIN
			SELECT TOP (@Rows) n.NotificationID
			,n.Title
			,CASE WHEN CAST(n.[DateTime] as date) = CAST(GETDATE() as date) THEN FORMAT(n.[DateTime], 'hh:mm tt') ELSE FORMAT(n.[DateTime], 'dd-MMM') END [DateTime]
			,ISNULL(nu.HasSeen,0) HasSeen 
			FROM [dbo].[Notification] n
			LEFT JOIN [dbo].[NotificationAndUser] nu ON n.NotificationID = nu.NotificationID AND nu.UserID = @UserID
			WHERE n.LocationID = @LocationID
			ORDER BY n.NotificationID DESC
		END
	ELSE IF(@IsNewer = 0) --Old records
		BEGIN
			SELECT TOP (@Rows) n.NotificationID
			,n.Title
			,CASE WHEN CAST(n.[DateTime] as date) = CAST(GETDATE() as date) THEN FORMAT(n.[DateTime], 'hh:mm tt') ELSE FORMAT(n.[DateTime], 'dd-MMM') END [DateTime]
			,ISNULL(nu.HasSeen,0) HasSeen 
			FROM [dbo].[Notification] n
			LEFT JOIN [dbo].[NotificationAndUser] nu ON n.NotificationID = nu.NotificationID AND nu.UserID = @UserID
			WHERE n.LocationID = @LocationID AND n.NotificationID < @MinID
			ORDER BY n.NotificationID DESC
		END
	ELSE -- New records
		BEGIN
			SELECT n.NotificationID
			,n.Title
			,CASE WHEN CAST(n.[DateTime] as date) = CAST(GETDATE() as date) THEN FORMAT(n.[DateTime], 'hh:mm tt') ELSE FORMAT(n.[DateTime], 'dd-MMM') END [DateTime]
			,ISNULL(nu.HasSeen,0) HasSeen 
			FROM [dbo].[Notification] n
			LEFT JOIN [dbo].[NotificationAndUser] nu ON n.NotificationID = nu.NotificationID AND nu.UserID = @UserID
			WHERE n.LocationID = @LocationID AND n.NotificationID > @MaxID
			ORDER BY n.NotificationID DESC
		END
 END


