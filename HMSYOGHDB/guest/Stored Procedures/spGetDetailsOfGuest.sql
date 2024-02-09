CREATE PROCEDURE [guest].[spGetDetailsOfGuest]
(
	@UserId int=Null, --Added by Arabinda on 20-04-2023
	@Action int=Null --Added by Arabinda on 20-04-2023
)
AS
BEGIN
	SET NOCOUNT ON;

	
	if @Action=1  --Black Listed
		begin
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage	FROM  general.Customer g
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
			where g.CustomerID in (SELECT CUSTOMERID FROM GUEST.BLACKLIST WHERE BLTYPEID =2)
			ORDER BY g.CustomerID DESC ----	
		end
	else if @Action=2	--Soft deleted
		BEGIN
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage		FROM  general.Customer g
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
			where g.CustomerID in (SELECT CUSTOMERID FROM GUEST.softdelete WHERE IsActive=1 and sdstatus=1 )
			ORDER BY g.CustomerID DESC ----	
		END

	else if @Action=3 --Not checkedin
		BEGIN
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage		FROM  general.Customer g
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
			where g.CustomerID not in (SELECT distinct CustomerID FROM guest.SoftDelete)
			and g.CustomerID not in (SELECT distinct guestid FROM reservation.Reservation WHERE ReservationStatusID in(1,2,3,4) )
			ORDER BY g.CustomerID DESC ----	
		END
	else if @Action=4 --Repeaters
		BEGIN
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage		FROM  general.Customer g
			INNER JOIN GUEST.Guest GG ON G.ContactID=GG.ContactID
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
			where g.CustomerID not in (SELECT distinct CustomerID FROM guest.SoftDelete) and
			 GG.GuestID in (SELECT GuestID FROM reservation.Reservation WHERE ReservationStatusID in(4) GROUP BY GuestID HAVING count(GuestID)>1 )
			--ORDER BY g.CustomerID		
			-- g.ContactID in(select ContactID from guest.Guest where GuestID in
			--(SELECT GuestID FROM reservation.Reservation WHERE ReservationStatusID in(4) GROUP BY GuestID HAVING count(GuestID)>1) )
			ORDER BY g.CustomerID DESC ----	
			


		END
	else if @Action=5 --In-House Birthday list
		BEGIN
			--SELECT DISTINCT g.CustomerID
			--,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			--,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			--,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			--,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			--,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			--,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			--,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			--,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			--,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			--,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			--RT.[ReservationType]	FROM  general.Customer g
			--INNER JOIN  [contact].[Details] d ON g.ContactID = d.ContactID
			--INNER JOIN  [contact].[Address] a ON d.ContactID = a.ContactID AND a.IsDefault = 1
			--INNER JOIN  [person].[Title] t ON d.TitleID = t.TitleID
			--INNER JOIN  [general].[Country] c ON a.CountryID = c.CountryID	
			--LEFT JOIN  [person].[IDCardType] idct ON d.IDCardTypeID = idct.IDCardTypeID
			--LEFT JOIN  [person].[MaritalStatus] ms ON d.MaritalStatusID = ms.MaritalStatusID
			--LEFT JOIN  [person].[Occupation] o ON d.OccupationID = o.OccupationID	
			--LEFT JOIN  [general].[Language] l ON d.LanguageID = l.LanguageID
			--LEFT JOIN  [contact].[AddressType] at ON a.AddressTypeID = at.AddressTypeID
			--left join  general.Image GI on GI.ImageID=d.ImageID
			--LEFT JOIN [reservation].[ReservationType] RT ON  RT.ReservationTypeID = g.ReservationTypeID
			--where g.CustomerID not in (SELECT distinct CustomerID FROM guest.SoftDelete)
			--and g.CustomerID in (SELECT distinct guestid FROM reservation.Reservation WHERE ReservationStatusID in(3) )
			--and d.DOB=GETDATE()
			--ORDER BY g.CustomerID

			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage		FROM  general.Customer g
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
			--where g.CustomerID not in (SELECT distinct CustomerID FROM guest.SoftDelete)
			and g.CustomerID in (SELECT distinct guestid FROM reservation.Reservation WHERE ReservationStatusID in(3))
			where  CONVERT(VARCHAR(5), DOB, 101) = CONVERT(VARCHAR(5), GETDATE(), 101)
			--and d.DOB=GETDATE()
			ORDER BY g.CustomerID DESC ----	
			
		END
	else if @Action=6 --In-House Anniversery list --Anniversery data is not available hence the result will be 0
		BEGIN
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],ISNULL(GI.GuestImage,'') as GuestImage FROM  general.Customer g
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
			where g.CustomerID not in (SELECT distinct CustomerID FROM guest.SoftDelete)
			and g.CustomerID not in (SELECT distinct guestid FROM reservation.Reservation WHERE ReservationStatusID in(1,2,3,4) )
			ORDER BY g.CustomerID DESC ----	
		END
	else --All list 
		BEGIN
	
			SELECT DISTINCT g.CustomerID
			,CustomerNo	,d.[ContactID]	,t.[TitleID]	,[Title]	,UPPER([FirstName]) [FirstName]
			,ISNULL(UPPER([LastName]),'') [LastName]    ,ISNULL(CONVERT(VARCHAR,d.[DOB]),'') [DOB]
			,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	,ISNULL([MaritalStatus],'') [MaritalStatus]
			,ISNULL(l.[LanguageID],0) [LanguageID]	,ISNULL([Language],'') [Language]
			,ISNULL(o.[OccupationID],0) [OccupationID]	,ISNULL([Occupation],'') [Occupation]
			,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	,ISNULL(IDCardTypeName,'') [IDCardTypeName]
			,ISNULL([IDCardNumber],'') [IDCardNumber]	,at.[AddressTypeID]	,[AddressType]
			,ISNULL(a.[Street],'') [Street]	,ISNULL(a.[City],'') [City]	,ISNULL(a.[State],'') [State]
			,ISNULL(a.[ZipCode],'') [ZipCode]	,c.[CountryID]	,[CountryName]	,a.[PhoneNumber]
			,ISNULL(a.[Email],'') [Email]	,a.[AddressID]	,ISNULL(GI.ImageUrl,'')ImageUrl,	g.[ReservationTypeID],
			RT.[ReservationType],
			CASE WHEN gb.CUSTOMERID is not null THEN 'Black Listed' WHEN gs.CUSTOMERID IS NOT NULL THEN 'Soft Deleted'
			ELSE 'Not CheckedIn' END [Status], ISNULL(GI.GuestImage,'') as GuestImage
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
			LEFT JOIN GUEST.BLACKLIST gb ON g.CustomerID = gb.CUSTOMERID AND gb.BLTYPEID = 2
			LEFT JOIN GUEST.softdelete gs ON g.CustomerID = gs.CUSTOMERID AND gs.IsActive=1 and sdstatus=1			
			ORDER BY g.CustomerID DESC ----	
		END
END
