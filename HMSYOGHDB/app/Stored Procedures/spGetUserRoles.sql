
CREATE Proc [app].[spGetUserRoles]
(	
	@UserID INT = NULL,
	@LocationID INT = NULL,
	@IsYsecITAdmin bit = NULL
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@UserID IS NULL AND @LocationID IS NULL AND @IsYsecITAdmin IS NULL)
		BEGIN
			SELECT r.RoleID, r.[Role]
			FROM  [app].[Roles] r	
			ORDER BY r.[DisplayOrder] ASC		
		END
	ELSE IF(@IsYsecITAdmin = 1)
		BEGIN
			SELECT r.RoleID, r.Role,CASE WHEN ur.RoleID > 0 THEN 1 ELSE 0 END AS [IsAssigned] 
			FROM  [app].[Roles] r
			LEFT JOIN  [app].[UsersAndRoles] ur ON r.RoleID = ur.RoleID AND ur.UserID = @UserID
			WHERE IsActive = 1
			ORDER BY r.[DisplayOrder] ASC		
		END
	ELSE
		BEGIN
			SELECT r.RoleID,r.Role,CASE WHEN ur.RoleID > 0 THEN 1 ELSE 0 END AS [IsAssigned] 
			FROM  [app].[Roles] r
			LEFT JOIN  [app].[UsersAndRoles] ur ON r.RoleID = ur.RoleID AND ur.UserID = @UserID
			WHERE IsActive = 1 AND r.RoleId <> 8
			ORDER BY r.[DisplayOrder] ASC		
		END   
END











