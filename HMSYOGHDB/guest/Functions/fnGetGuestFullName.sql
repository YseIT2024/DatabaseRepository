

CREATE FUNCTION [guest].[fnGetGuestFullName]
(
	@GuestID int
)
RETURNS varchar(100)
AS
BEGIN
	Declare @Name varchar(100);

	SELECT @Name = t.Title + ' ' + d.FirstName + CASE WHEN d.LastName IS NULL THEN '' ELSE ' '+ d.LastName END
	
	FROM [guest].[Guest] g	
	INNER JOIN [contact].[Details] d on g.ContactID = d.ContactID
	INNER JOIN [person].[Title] t on d.TitleID = t.TitleID	
	WHERE g.GuestID = @GuestID

	RETURN ISNULL(@Name,'')
END










