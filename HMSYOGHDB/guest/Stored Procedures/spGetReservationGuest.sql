-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [guest].[spGetReservationGuest]
(
	@GuestID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT g.[GuestID]
	,d.[ContactID]
	,t.[TitleID]	
	,ca.[AddressTypeID]
	,c.[CountryID]	
	,a.[PhoneNumber]
	,a.[AddressID]
	,UPPER([FirstName]) [FirstName]
	,ISNULL(UPPER([LastName]),'') [LastName]
    ,ISNULL(CONVERT(varchar,d.[DOB]),'') [DOB]
	,ISNULL(ms.[MaritalStatusID],0) [MaritalStatusID]	
	,ISNULL(l.[LanguageID],0) [LanguageID]	
	,ISNULL(ft.FoodTypeID,0) [FoodTypeID]	
	,ISNULL(o.[OccupationID],0) [OccupationID]	
	,ISNULL(idct.IDCardTypeID,0) [IDCardTypeID]	
	,ISNULL([IDCardNumber],'') [IDCardNumber]
	,ISNULL([Reference],'') [Reference]
	,ISNULL([GroupCode],'') [GroupCode]	
	,ISNULL(a.[Street],'') [Street]
	,ISNULL(a.[City],'') [City]
	,ISNULL(a.[State],'') [State]
	,ISNULL(a.[ZipCode],'') [ZipCode]	
	,ISNULL(a.[Email],'') [Email]	
	FROM [guest].[Guest] g
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID
	INNER JOIN [contact].[Address] a ON d.ContactID = a.ContactID AND a.IsDefault = 1
	INNER JOIN [person].[Title] t ON d.TitleID = t.TitleID
	INNER JOIN [general].[Country] c ON a.CountryID = c.CountryID	
	LEFT JOIN [person].[IDCardType] idct ON d.IDCardTypeID = idct.IDCardTypeID
	LEFT JOIN [person].[MaritalStatus] ms ON d.MaritalStatusID = ms.MaritalStatusID
	LEFT JOIN [person].[Occupation] o ON d.OccupationID = o.OccupationID	
	LEFT JOIN [general].[Language] l ON d.LanguageID = l.LanguageID
	LEFT JOIN [general].[FoodType] ft ON g.FoodTypeID = ft.FoodTypeID
	LEFT JOIN [contact].[AddressType] ca ON a.AddressTypeID = ca.AddressTypeID
	WHERE g.GuestID = @GuestID
END


