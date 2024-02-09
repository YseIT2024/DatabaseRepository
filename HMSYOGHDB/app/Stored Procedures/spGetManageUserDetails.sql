
CREATE Proc [app].[spGetManageUserDetails] --true
(
	@IsYsecITAdmin bit
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT DISTINCT u.UserID
	,u.UserName
	,d.FirstName
	,ISNULL(d.LastName,'') LastName
	,u.[Password]
	,ul.LocationID
	,CASE WHEN u.IsPOSUser = 1 THEN 'Yes' ELSE 'No' END [IsPOSUser]
	,CASE WHEN u.IsActive = 1 THEN 'Yes' ELSE 'No' END [IsActive] 
	,(
		SELECT COUNT(obj.ObjectID) FROM
		(
			SELECT DISTINCT o.[ObjectID]
			FROM  [app].[UserRoleObjects] ur
			INNER JOIN  app.[Object] o ON ur.ObjectID = o.ObjectID		
			WHERE ur.RoleID IN (SELECT RoleID FROM  app.UsersAndRoles WHERE UserID = u.UserID)	
			UNION
			SELECT DISTINCT o.[ObjectID]
			FROM  [app].[UserRight] ur
			INNER JOIN  app.[Object] o ON ur.ObjectID = o.ObjectID		
			WHERE ur.UserID = u.UserID
		) obj
	) [Objects]	
	FROM  app.[User] u
	INNER JOIN  contact.[Details] d ON u.ContactID = d.ContactID
	INNER JOIN  app.[UserAndLocation] ul	ON u.UserID = ul.UserID
	WHERE ul.IsPrimary = 1
	AND u.UserID NOT IN (SELECT CASE WHEN @IsYsecITAdmin = 0 THEN 1 ELSE 0 END) -- Exclude YsecIT User for other users 
	ORDER BY d.FirstName, ISNULL(d.LastName,'')

	SELECT DISTINCT  EmployeeID, FirstName + ' ' + ISNULL(LastName,'') EmployeeName 
	FROM person.[vwEmployeeDetails] 
	WHERE ContactID NOT IN(SELECT DISTINCT ContactID FROM  app.[User])

	SELECT DISTINCT ur.UserID, LTRIM(RTRIM(r.Role)) [Role]
	FROM  app.UsersAndRoles ur 
	INNER JOIN  app.Roles r ON ur.RoleID = r.RoleID		
	
	SELECT DISTINCT ual.UserID, l.LocationCode
	FROM  app.UserAndLocation ual
	INNER JOIN  general.[Location] l ON ual.LocationID = l.LocationID	
END


