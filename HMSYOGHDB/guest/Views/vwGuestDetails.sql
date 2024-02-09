


CREATE VIEW [guest].[vwGuestDetails]
AS
	SELECT DISTINCT 
	g.GuestID, d.TitleID
	,(SELECT dbo.fnPascalCase(FirstName)) [FirstName]
	,(SELECT dbo.fnPascalCase(LastName)) [LastName]
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]	
	,ISNULL(ad.Street, '') AS Street, ISNULL(ad.City, '') AS City, ISNULL(ad.ZipCode, '') AS ZipCode, ISNULL(ad.[State], '') AS [State]
	,ISNULL(c.CountryName, '') AS CountryName, ISNULL(ad.Email, '') AS Email
	,ISNULL(ad.PhoneNumber, '') AS PhoneNumber, r.LocationID
	,g.CMSCustomerID
	FROM guest.Guest AS g 	
	INNER JOIN contact.Details AS d ON g.ContactID = d.ContactID 
	INNER JOIN person.Title AS t ON d.TitleID = t.TitleID 	
	INNER JOIN contact.[Address] AS ad ON g.ContactID = ad.ContactID AND ad.IsDefault = 1 	
	INNER JOIN general.Country AS c ON ad.CountryID = c.CountryID 
	LEFT OUTER JOIN reservation.Reservation AS r ON g.GuestID = r.GuestID 
	Left JOIN general.Customer gc on g.ContactID=gc.ContactID   --Added by Arabinda on 10-06-2023 to retrive if the customer is available in Customer table
	
