-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [account].[spGetAccountGroups]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	   SELECT AccountGroupID
	   ,ISNULL(AccountGroupNumber,0) [AccountGroupNumber]
	   ,AccountGroup
	   ,g.MainAccountTypeID
	   ,m.MainAccountType MainAccount
	   ,ISNULL(g.Description,'') Description
	   FROM [account].[MainAccountType] m
	   INNER JOIN [account].[AccountGroup] g ON M.MainAccountTypeID = g.MainAccountTypeID
END










