-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [person].[spGetEmployeeDocument] --1
	-- Add the parameters for the stored procedure here
(
	@LocationID INT = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT ContactID, [Title] + [FirstName] + ' ' + ISNULL([LastName],'') AS EmployeeName
	FROM [person].[vwEmployeeDetails] ed
	Where ed.IsActive = 1	
	ORDER BY ed.EmployeeIDNumber 

	SELECT ed.ContactID, gd.DocumentID, gd.DocumentUrl, it.IDCardTypeName AS DocumentType,
	gd.DocumentUrl AS Viewer, gd.DocumentID AS [Delete]
	FROM [person].[vwEmployeeDetails] ed
	INNER JOIN [contact].[Document] cd ON ed.ContactID = cd.ContactID
	INNER JOIN [general].[Document] gd ON cd.DocumentID = gd.DocumentID
	INNER JOIN [person].[IDCardType] it ON gd.IDCardTypeID = it.IDCardTypeID
	Where ed.IsActive = 1	and gd.IsActive = 1
	ORDER BY ed.EmployeeIDNumber 
END
