
CREATE PROCEDURE [person].[spGetEmployeeByLocation]-- 1 
(
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT [EmployeeID]
	,[ContactID]
	,[TitleID]
	,[Title]
	,[FirstName]
	,[LastName]
	,[GenderID]	
	,[Street]
	--,[City]
	--,[State]
	--,[ZipCode]
	,[CountryID]
	,[PersonalEmail]
	,[OfficialEmail]
	,[PhoneNumber]	
	,CASE WHEN DOB IS NOT NULL THEN FORMAT(DOB,'dd-MMM-yyyy') ELSE '' END [DOB]	
	,CASE WHEN JoiningDate IS NOT NULL THEN FORMAT(JoiningDate,'dd-MMM-yyyy') ELSE '' END [DOJ]
	--,[MaritalStatusID]	
	--,[Language]
	--,[LanguageID]	
	,[IDCardTypeID]
	,[IDCardNumber]		
	,[DesignationID]
	,[Designation]
	,[DepartmentID]
	,[Department]
	,[IsActive]
	,[CountryName]
	,[AddressTypeID]	
	--,[ImageID]
	--,[ImageUrl]
	,[AddressID]
	,[IsActive]
	,[Remarks]
	,HrmsEmpID
	FROM [person].[vwEmployeeDetails] ed
	ORDER BY ed.EmployeeID DESC ----	
	--Where ed.IsActive = 1	

	SELECT EmployeeID, eal.LocationID, l.LocationName [Location]
	FROM  general.EmployeeAndLocation eal
	INNER JOIN  general.[Location] l ON eal.LocationID = l.LocationID
	--ORDER BY eal.EmployeeID DESC ----	
END










