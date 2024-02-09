-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetDrawers]
(
	@LocationID INT 
)
AS
BEGIN
	IF((SELECT COUNT(DrawerID) FROM app.Drawer WHERE LocationID = @LocationID AND IsActive =1) > 1)
	BEGIN
		SELECT 0 DrawerID,'All' Drawer
		UNION
		SELECT DrawerID,Drawer FROM app.Drawer WHERE LocationID = @LocationID AND IsActive =1
		ORDER BY DrawerID
	END
	ELSE
	BEGIN
		SELECT DrawerID,Drawer FROM app.Drawer WHERE LocationID = @LocationID AND IsActive =1
	
	END
	
END

