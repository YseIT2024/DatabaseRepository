
CREATE PROCEDURE [company].[spGetCompanies]
AS
BEGIN
	SELECT c.[CompanyID],[CompanyName] Name,[CompanyType],[Address],c.[PhoneNumber], CASE WHEN c.ContactID = 0 THEN '' ELSE FirstName END AS ContactPerson, 
	a.PhoneNumber as ContactPersonPhone,a.Email as ContactPersonEmail, ISNULL(c.ContactID,0) ContactID, CASE WHEN ccp.IsActive = 1 THEN 'Yes' ELSE 'No' END [IsActive]
	FROM [company].[Company] c 
	LEFT JOIN [company].[CompanyAndContactPerson] ccp ON c.CompanyID = ccp.CompanyID AND c.ContactID = ccp.ContactID
	LEFT JOIN [contact].[Details] d ON c.ContactID = d.ContactID
	LEFT JOIN [contact].[Address] a ON c.ContactID = a.ContactID
 	WHERE c.CompanyID > 0 
	ORDER BY [CompanyName] 
END

