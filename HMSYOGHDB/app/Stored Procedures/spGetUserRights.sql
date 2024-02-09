
CREATE PROCEDURE [app].[spGetUserRights]
(
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT @UserID [UserID]
	,ISNULL(usrObj.OperationId,0) [OperationId]
	,o.ObjectId
	,t.DisplayText [TabName]
	,tg.DisplayText [TabGroupName]
	,o.ObjectName
	,o.DisplayText
	,o.ObjectPath			
	,CASE WHEN usrObj.ObjectID IS NULL THEN CONVERT(bit, 0) WHEN usrObj.OperationId = 1 THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END [IsFullAccess]
	,CASE WHEN usrObj.ObjectID IS NULL THEN CONVERT(bit, 0) WHEN usrObj.OperationId = 2 THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END [IsReadOnly]
	,CASE WHEN IsAutoObject = 1 Then 'Auto' ELSE 'Manual' END [Type]
	FROM app.[Object] o
	INNER JOIN app.TabGroup tg ON o.TabGroupID = tg.TabGroupID
	INNER JOIN app.Tab t ON tg.TabID = t.TabID
	LEFT JOIN 
	(
		SELECT ObjectID, OperationId FROM app.UserRight
		WHERE UserID = @UserID
		UNION
		SELECT[ObjectID], [OperationID] FROM [app].[UserRoleObjects] uro
		INNER JOIN [app].[UsersAndRoles] uar ON uro.RoleID = uar.RoleID
		WHERE uar.UserID = @UserID
	) as usrObj ON o.ObjectID = usrObj.ObjectID
	ORDER BY t.DisplayText ASC
END

