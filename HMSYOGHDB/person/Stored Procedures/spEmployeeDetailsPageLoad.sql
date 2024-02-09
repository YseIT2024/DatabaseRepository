

CREATE Proc [person].[spEmployeeDetailsPageLoad]
AS
BEGIN
	SET NOCOUNT ON;	
                    
	SELECT TitleID, Title
	FROM  person.Title

	SELECT CountryID, CountryName
	FROM  general.Country
	WHERE IsActive = 1
                    
	SELECT MaritalStatusID, MaritalStatus
	FROM  person.MaritalStatus

	SELECT LanguageID,[Language]
	FROM  general.[Language]
	
	SELECT IDCardTypeID,IDCardTypeName
	FROM  person.IDCardType
	
	SELECT DepartmentID, Department
	FROM  general.Department
	ORDER BY Department

	SELECT DesignationID, Designation
	FROM  general.Designation
	ORDER BY Designation
                    
	SELECT AddressTypeID, AddressType
	FROM  contact.AddressType

	SELECT LocationID, LocationName
	FROM  general.[Location]
	WHERE IsActive = 1
END


