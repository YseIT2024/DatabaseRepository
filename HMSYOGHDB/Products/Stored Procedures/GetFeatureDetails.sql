-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [Products].[GetFeatureDetails] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT fDetail.[FeatureID], fDetail.[CategoryID], cat.[Name] as Category, fDetail.[Name], fDetail.[Group], fDetail.[Remarks], fDetail.[IsActive]
    FROM  [Products].[Features] fDetail
	INNER JOIN  [Products].[Category] cat
	ON fDetail.CategoryID = cat.CategoryID

	SELECT [CategoryID], [Name] as Category
	FROM  [Products].[Category]

END



