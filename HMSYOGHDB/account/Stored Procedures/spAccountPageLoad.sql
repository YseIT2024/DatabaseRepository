

CREATE PROCEDURE [account].[spAccountPageLoad]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [MainAccountTypeID] ,[MainAccountType] 
	FROM [account].[MainAccountType]

	SELECT [AccountGroupID] ,[AccountGroup] ,[MainAccountTypeID] 
	FROM [account].[AccountGroup]

	SELECT 0 [TransactionTypeID] ,'PAY/REC' [TransactionType]
	UNION ALL
	SELECT [TransactionTypeID] ,[TransactionType]
	FROM [account].[TransactionType]
	WHERE ShowInUI = 1
END







