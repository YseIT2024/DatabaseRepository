-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [app].[spGetTableStructureDefaultData] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT  [LocationID] ,[LocationName]
    FROM  [general].[Location] where [LocationTypeID] IN(2,3,5)

	SELECT [StatusID],[Status]
    FROM  [Restaurant].[TableStatus] WHERE [StatusID] IN(1,4)
END



