
CREATE Proc [guest].[spGetGuestByNameAndIDCard]
(
	@FirstName varchar(100) = NULL,
	@LastName varchar(100) = NULL,
	@IDCardNumber varchar(30) = NULL,
	@PhoneNumber varchar(30) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	IF (@FirstName IS NOT NULL)
		Begin
			SELECT DISTINCT 
			GuestID
			,Title
			,[FirstName]
			,[LastName]
			,(CASE When LEN([Street]) > 0 THEN [Street] + ', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] + ', ' ELSE '' END) 
			+ (CASE When LEN([State]) > 0 THEN [State] + ', ' ELSE '' END) + [CountryName] as [Address]
			,Email
			,PhoneNumber
			,'' IDCardNumber 
			,CASE WHEN vwg.[CMSCustomerID] IS NULL THEN '' ELSE CAST([CMSCustomerID] as varchar(15)) END [CMSCustomerID]
			FROM person.Title t
			INNER JOIN  [guest].[vwGuestDetails] vwg ON t.TitleID = vwg.TitleID
			WHERE FirstName LIKE '%' + @FirstName + '%'
			ORDER BY GuestID DESC
		End
	ELSE IF (@LastName IS NOT NULL)
		Begin
			SELECT DISTINCT 
			GuestID
			,Title 
			,[FirstName]
			,[LastName]
			,(CASE When LEN([Street]) > 0 THEN [Street] + ', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] + ', ' ELSE '' END) 
			+ (CASE When LEN([State]) > 0 THEN [State] + ', ' ELSE '' END) + [CountryName] as [Address]
			,Email
			,PhoneNumber
			,'' IDCardNumber 
			,CASE WHEN vwg.[CMSCustomerID] IS NULL THEN '' ELSE CAST([CMSCustomerID] as varchar(15)) END [CMSCustomerID]
			FROM person.Title t
			INNER JOIN  [guest].[vwGuestDetails] vwg ON t.TitleID = vwg.TitleID
			WHERE LastName LIKE '%' + @LastName + '%' 
			ORDER BY GuestID DESC
		End	
	ELSE IF (@PhoneNumber IS NOT NULL)
		Begin
			SELECT DISTINCT 
			GuestID
			,Title 
			,[FirstName]
			,[LastName]
			,(CASE When LEN([Street]) > 0 THEN [Street] + ', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] + ', ' ELSE '' END) 
			+ (CASE When LEN([State]) > 0 THEN [State] + ', ' ELSE '' END) + [CountryName] as [Address]
			,Email
			,PhoneNumber
			,''IDCardNumber 
			,CASE WHEN vwg.[CMSCustomerID] IS NULL THEN '' ELSE CAST([CMSCustomerID] as varchar(15)) END [CMSCustomerID]
			FROM person.Title t
			INNER JOIN  [guest].[vwGuestDetails] vwg ON t.TitleID = vwg.TitleID
			WHERE PhoneNumber LIKE '%' + @PhoneNumber + '%'
			ORDER BY GuestID DESC
		End  
	ELSE
		Begin
			SELECT DISTINCT 
			GuestID
			,Title 
			,[FirstName]
			,[LastName]
			,(CASE When LEN([Street]) > 0 THEN [Street] + ', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] + ', ' ELSE '' END) 
			+ (CASE When LEN([State]) > 0 THEN [State] + ', ' ELSE '' END) + [CountryName] as [Address]
			,Email
			,PhoneNumber
			,''IDCardNumber 
			,CASE WHEN vwg.[CMSCustomerID] IS NULL THEN '' ELSE CAST([CMSCustomerID] as varchar(15)) END [CMSCustomerID]
			FROM person.Title t
			INNER JOIN  [guest].[vwGuestDetails] vwg ON t.TitleID = vwg.TitleID
			ORDER BY GuestID DESC
		End  
END


