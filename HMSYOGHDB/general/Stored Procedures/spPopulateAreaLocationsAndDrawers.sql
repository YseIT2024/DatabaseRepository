
CREATE PROCEDURE [general].[spPopulateAreaLocationsAndDrawers] --1
(
	@UserID INT
)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT l.LocationID,LocationCode + ' ('+LocationName+')' LocationCode
	FROM general.Location l
	INNER JOIN app.UserAndLocation ul ON l.LocationID = ul.LocationID
	WHERE ul.UserID = @UserID
	Order by l.LocationID

	SELECT d.DrawerID, Drawer,LocationID 
	FROM app.Drawer d
	INNER JOIN app.UserDrawer ud ON d.DrawerID = ud.DrawerID
	WHERE UserID = @UserID
	ORDER BY d.DrawerID
END










