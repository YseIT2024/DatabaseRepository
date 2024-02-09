-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [app].[spGetManageUserPageLoad] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT LocationID,CONCAT(LocationCode,' (',LocationName,')') LocationCode 
	FROM  general.[Location]

	SELECT DrawerID,Drawer,LocationID 
	FROM  [app].[Drawer] 
	WHERE IsActive = 1
END


