
CREATE Proc [app].[spGetUserRoleObjects]
(
	@RoleID INT 
)
AS
BEGIN
	SET NOCOUNT ON 
	-- added to prevent extra result sets from
	-- interfering with SELECT statements.

	SELECT @RoleID RoleID
	,ISNULL(uro.OperationId,0) [OperationId]
	,ob.ObjectId
	,t.DisplayText [TabName]
	,tg.DisplayText [TabGroupName]
	,ob.ObjectName
	,ob.DisplayText
	,ob.ObjectPath			
	,CASE WHEN uro.OperationId = 1 THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END AS IsFullAccess
	,CASE WHEN uro.OperationId = 2 THEN CONVERT(bit, 1) ELSE CONVERT(bit, 0) END AS IsReadOnly
	,CASE WHEN IsAutoObject = 1 Then 'Auto' ELSE 'Manual' END [Type]
	FROM  app.[Object] ob
	INNER JOIN  app.TabGroup tg ON ob.TabGroupID = tg.TabGroupID
	INNER JOIN  app.Tab t ON tg.TabID = t.TabID
	LEFT JOIN
	(
		SELECT RoleID, ObjectID, OperationID FROM  app.UserRoleObjects WHERE RoleID = @RoleID 
	)uro ON uro.ObjectID = ob.ObjectID
	ORDER BY t.DisplayText ASC
END


