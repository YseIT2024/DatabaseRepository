
CREATE Proc [guest].[spAddNewGuestPageLoad] 
(
	@GuestID int
)
AS
BEGIN	
	SELECT TitleID, Title
	FROM person.Title	
	
	SELECT CountryID, CountryName  
	FROM general.Country
	WHERE IsActive = 1

	SELECT GuestID, FirstName, LastName, PhoneNumber, CountryID, TitleID 
	FROM guest.Guest gg
	INNER JOIN contact.Details d ON gg.ContactID = d.ContactID
	INNER JOIN contact.Address a ON d.ContactID = a.ContactID
	WHERE gg.GuestID = @GuestID
END



