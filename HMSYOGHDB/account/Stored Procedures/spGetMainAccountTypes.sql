-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [account].[spGetMainAccountTypes]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT MainAccountTypeID,ISNULL(MainAccountNumber,0) [MainAccountNumber],MainAccountType,Description FROM [account].[MainAccountType]
    
END










