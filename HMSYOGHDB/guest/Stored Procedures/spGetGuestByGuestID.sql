
CREATE Proc [guest].[spGetGuestByGuestID]--1416
(
	@GuestID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT TOP 1 [GuestID]	
	,t.[TitleID] [TitleID]	
	,[Title]
	,[FirstName]
	,[LastName]
	,[Email]
	,[PhoneNumber]		
	,a.[CountryID]	
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address]
	From [guest].[Guest] g 
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID
	INNER JOIN [contact].[Address] a ON g.ContactID = a.ContactID
	INNER JOIN [general].[Country] c ON a.CountryID = c.CountryID
	INNER JOIN [person].[Title] t ON d.TitleID = t.TitleID
	Where g.GuestID = @GuestID	
END










