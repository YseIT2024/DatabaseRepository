
CREATE PROCEDURE [guest].[spGetGuestDetails]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT g.[GuestID]
	,d.FirstName + CASE WHEN d.LastName IS NULL THEN '' ELSE ' '+ d.LastName END [Name]
	,ISNULL(o.Occupation,'Occupation Not Available') [Occupation]
	,ISNULL(g.Reference,'') [Reference]
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address]
	,ISNULL(ad.Email,'') Email
	,ISNULL(ad.PhoneNumber,'') PhoneNumber
	,t.GenderID
	FROM [guest].[Guest] g
	INNER JOIN [contact].[Address] ad on g.ContactID = ad.ContactID
	INNER JOIN [general].[Country] c on ad.CountryID = c.CountryID
	INNER JOIN [contact].[Details] d on g.ContactID = d.ContactID
	INNER JOIN [person].[Title] t on d.TitleID = t.TitleID	
	LEFT JOIN [person].[Occupation] o on d.OccupationID = o.OccupationID
	ORDER BY [Name]

	SELECT g.GuestID, l.LocationCode
	FROM [guest].[Guest] g
	INNER JOIN (SELECT DISTINCT GuestID, LocationID FROM reservation.Reservation) r ON g.GuestID = r.GuestID
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID
END









