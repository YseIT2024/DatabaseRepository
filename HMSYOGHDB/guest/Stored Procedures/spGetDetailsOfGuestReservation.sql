
CREATE PROCEDURE [guest].[spGetDetailsOfGuestReservation]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT g.CustomerID
	,CustomerNo
	,d.[ContactID]
	,t.[TitleID]
	,[Title]
	,UPPER([FirstName]) [FirstName]
	,ISNULL(UPPER([LastName]),'') [LastName]
    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
	,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]
	,ISNULL([MaritalStatus],'') [MaritalStatus]
	,ISNULL(l.[LanguageID],0) [LanguageID]
	,ISNULL([Language],'') [Language]
	,ISNULL(o.[OccupationID],0) [OccupationID]
	,ISNULL([Occupation],'') [Occupation]
	,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]
	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
	,ISNULL([IDCardNumber],'') [IDCardNumber]
	,at.[AddressTypeID]
	,[AddressType]
	,ISNULL(a.[Street],'') [Street]
	,ISNULL(a.[City],'') [City]
	,ISNULL(a.[State],'') [State]
	,ISNULL(a.[ZipCode],'') [ZipCode]
	,c.[CountryID]
	,[CountryName]
	,a.[PhoneNumber]
	,ISNULL(a.[Email],'') [Email]
	,a.[AddressID]
	,ISNULL(GI.ImageUrl,'')ImageUrl,
	g.[ReservationTypeID],
	RT.[ReservationType],
	gt.GuestID,
	rr.ActualCheckIn,
	rr.ActualCheckOut

	FROM  general.Customer g
	INNER JOIN  [contact].[Details] d ON g.ContactID = d.ContactID
	INNER JOIN  [contact].[Address] a ON d.ContactID = a.ContactID AND a.IsDefault = 1
	INNER JOIN  [person].[Title] t ON d.TitleID = t.TitleID
	INNER JOIN  [general].[Country] c ON a.CountryID = c.CountryID	
	LEFT JOIN  [person].[IDCardType] idct ON d.IDCardTypeID = idct.IDCardTypeID
	LEFT JOIN  [person].[MaritalStatus] ms ON d.MaritalStatusID = ms.MaritalStatusID
	LEFT JOIN  [person].[Occupation] o ON d.OccupationID = o.OccupationID	
	LEFT JOIN  [general].[Language] l ON d.LanguageID = l.LanguageID
	LEFT JOIN  [contact].[AddressType] at ON a.AddressTypeID = at.AddressTypeID
	left join  general.Image GI on GI.ImageID=d.ImageID
	LEFT JOIN [reservation].[ReservationType] RT ON  RT.ReservationTypeID = g.ReservationTypeID
    LEFT JOIN guest.Guest gt on d.ContactID=gt.ContactID
	LEFT JOIN reservation.Reservation rr on rr.GuestID=gt.GuestID

	ORDER BY g.CustomerID
END