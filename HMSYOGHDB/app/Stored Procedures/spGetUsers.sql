
CREATE PROCEDURE [app].[spGetUsers]	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT u.UserID	
	,d.FirstName
	,ISNULL(d.LastName,'') LastName	
	FROM app.[UserAndLocation] ul
	INNER JOIN app.[User] u ON ul.UserID=u.UserID
	INNER JOIN contact.[Details] d ON u.ContactID=d.ContactID
	WHERE ul.IsPrimary = 1
	ORDER BY d.FirstName, ISNULL(d.LastName,'')	 
END

