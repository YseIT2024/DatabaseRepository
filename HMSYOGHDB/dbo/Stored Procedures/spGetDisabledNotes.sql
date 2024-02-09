
CREATE PROCEDURE [dbo].[spGetDisabledNotes]
(
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [NoteID]	
	,d.FirstName + ISNULL(' ' + d.LastName, '') [ALTERdBy]
	,[Notes]
	,FORMAT(n.[DateTime],'dd-MMM-yyyy') [DateTime]
	,[IsEnabled]
	,'Disabled' [Status]
	FROM [dbo].[Notes] n
	INNER JOIN app.[User] u ON n.[UserID] = u.[UserID]
	INNER JOIN contact.Details d ON u.ContactID = d.ContactID
	WHERE n.LocationID = @LocationID AND [IsEnabled] = 0
	ORDER BY [NoteID] DESC
END

