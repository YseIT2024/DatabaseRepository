CREATE PROCEDURE [dbo].[spGetNoteDetails]
(
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT [NoteID]
	,[LocationID]
	,n.[UserID]
	,d.FirstName + ISNULL(' ' + d.LastName, '') [ALTERdBy]
	,[Notes]
	,FORMAT(n.[DateTime],'dd-MMM-yyyy hh:mm tt') [DateTime]
	,[IsEnabled]
	FROM [dbo].[Notes] n
	INNER JOIN app.[User] u ON n.[UserID] = u.[UserID]
	INNER JOIN contact.Details d ON u.ContactID = d.ContactID
	WHERE n.LocationID = @LocationID AND [IsEnabled] = 1
	ORDER BY [NoteID] DESC
END

