










CREATE VIEW [person].[vwEmployeeDetails]
AS
	SELECT d.ContactID, ISNULL(d.TitleID,0) TitleID, 
	(SELECT dbo.fnPascalCase(FirstName)) [FirstName]
	,(SELECT dbo.fnPascalCase(LastName)) [LastName],
	ISNULL(t.Title,'') Title, ISNULL(d.GenderID,0) GenderID,
	ISNULL(g.Gender,'') Gender, ISNULL(a.Street,'') Street, ISNULL(a.City,'') City, ISNULL(a.[State], '') [State], a.ZipCode, a.CountryID, ISNULL(a.Email,'') PersonalEmail, e.OfficialEmail,
	ISNULL(a.PhoneNumber,'') PhoneNumber, DOB, ISNULL(d.MaritalStatusID,0) MaritalStatusID, ISNULL(ms.MaritalStatus,'') MaritalStatus, 
	ISNULL(d.LanguageID,0) LanguageID, ISNULL(d.OccupationID,0) OccupationID, ISNULL(o.Occupation,0) Occupation, ISNULL(d.IDCardTypeID,0) IDCardTypeID, 
	ISNULL(d.IDCardNumber,'') IDCardNumber, e.EmployeeID, eal.LocationID, l.LocationName, 
	l.LocationCode, d.DesignationID,d.DepartmentID, pd.Designation,gd.Department, e.JoiningDate, ISNULL(e.ResignationDate,'') ResignationDate, e.IsActive,e.Remarks, c.CountryName,
	adt.AddressTypeID, adt.AddressType,d.ImageID  ,ISNULL(i.ImageUrl,'') ImageUrl, ISNULL(gl.[Language],'') [Language], a.AddressID,e.HrmsEmpID
	FROM  general.Employee e
	--INNER JOIN  general.Designation pd ON e.DesignationID = pd.DesignationID	
	INNER JOIN  general.EmployeeAndLocation eal ON e.EmployeeID = eal.EmployeeID
	INNER JOIN  general.[Location] l ON eal.LocationID = l.LocationID
	INNER JOIN  contact.Details d ON e.ContactID = d.ContactID	
	INNER JOIN  contact.[Address] a ON e.ContactID = a.ContactID AND a.IsDefault = 1
	INNER JOIN  contact.AddressType adt ON a.AddressTypeID = adt.AddressTypeID 
	INNER JOIN  general.Country c ON a.CountryID = c.CountryID	
    INNER JOIN  general.Designation pd ON d.DesignationID = pd.DesignationID
	Inner join  general.Department gd on d.DepartmentID = gd.DepartmentID
	LEFT JOIN  person.Title t ON d.TitleID = t.TitleID
	LEFT JOIN  person.Gender g ON d.GenderID = g.GenderID
	LEFT JOIN  person.MaritalStatus ms ON d.MaritalStatusID = ms.MaritalStatusID
	LEFT JOIN  general.[Language] gl ON d.LanguageID = gl.LanguageID
	LEFT JOIN  person.Occupation o ON d.OccupationID = o.OccupationID	
	LEFT JOIN  general.[Image] i ON d.ImageID = i.ImageID











