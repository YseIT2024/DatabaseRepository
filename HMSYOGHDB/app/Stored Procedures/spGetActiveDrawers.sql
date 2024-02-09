-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [app].[spGetActiveDrawers] --1,1
(
@LocationID int,
@UserID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT d.DrawerID, Drawer
	FROM [app].[Drawer] d
	INNER JOIN 
	[app].[UserDrawer] ud ON d.DrawerID = ud.DrawerID AND ud.UserID = @UserID AND ud.IsPrimary = 1
	WHERE IsActive=1 AND LocationID = @LocationID

END










