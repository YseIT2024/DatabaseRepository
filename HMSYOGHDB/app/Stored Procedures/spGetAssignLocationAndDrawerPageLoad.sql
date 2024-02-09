CREATE Proc [app].[spGetAssignLocationAndDrawerPageLoad] --1,1
(
  @UserID INT,
  @LocationID INT
)	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 
	
			

	SELECT DISTINCT l.LocationID,LocationCode +' ('+LocationName+')' LocationCode,ISNULL(ul.IsPrimary,0) IsPrimary, 
	CASE WHEN ul.LocationID is null then 0 ELSE 1 END IsAssigned 
	FROM  general.[Location] l	
	LEFT JOIN 
	 [app].[UserAndLocation] ul ON l.LocationID = ul.LocationID AND uL.UserID = @UserID 	--AND ul.IsPrimary =1
	ORDER BY LocationID

	SELECT d.DrawerID,Drawer,l.LocationID,LocationCode +' ('+LocationName+')' Location, ISNULL(ud.IsPrimary,0) IsPrimary, 
	CASE WHEN ud.DrawerID > 0 THEN 1 ELSE 0 END AS [IsAssigned]
	FROM  [app].[Drawer] d
	INNER JOIN  general.[Location] l ON d.LocationID = l.LocationID
	LEFT JOIN 
	 [app].[UserDrawer] ud ON d.DrawerID = ud.DrawerID AND ud.UserID = @UserID --AND ud.IsPrimary = 1
	WHERE d.IsActive=1 

END











