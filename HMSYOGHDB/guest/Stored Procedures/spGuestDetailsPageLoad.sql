

CREATE Proc [guest].[spGuestDetailsPageLoad]
AS
BEGIN	
	

	SELECT TitleID, Title
	FROM  person.Title	

    SELECT 0 MaritalStatusID, 'Select Marital Status' MaritalStatus  
	UNION
	SELECT MaritalStatusID, MaritalStatus
	FROM  person.MaritalStatus

	--SELECT 0 FoodTypeID, 'Select Food Type' FoodType
	--UNION
	--SELECT FoodTypeID, FoodType
	--FROM general.FoodType

	SELECT 0 OccupationID, 'Select Occupation' Occupation
	UNION
	SELECT OccupationID, Occupation
	FROM  person.Occupation
	
	SELECT 0 IDCardTypeID, 'Select ID Card Type' IDCardTypeName
	UNION
	SELECT IDCardTypeID, IDCardTypeName
	FROM  person.IDCardType

	SELECT 0 LanguageID, 'Select Language' [Language]
	UNION
	SELECT LanguageID, [Language]
	FROM  general.[Language]	

	SELECT AddressTypeID, AddressType
	FROM  contact.AddressType

	SELECT CountryID, CountryName  
	FROM  general.Country
	WHERE IsActive = 1

	Declare @CustomerPrefix varchar(20);
	select @CustomerPrefix= isnull([value],'CUS') from  app.Parameter where ParameterID =1

	select  @CustomerPrefix+convert(varchar, isnull(max(CustomerID),0)+ 1001) as CustomerNo 
	from  general.Customer 

	--SELECT 0 ReservationTypeID, 'Select Type' ReservationType
	--UNION
	SELECT [ReservationTypeID], [ReservationType] FROM [reservation].[ReservationType] where [IsActive] = 1 and ReservationTypeID not in(4,8,11)
		
END










