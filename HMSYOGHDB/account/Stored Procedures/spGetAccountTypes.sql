
CREATE PROCEDURE [account].[spGetAccountTypes]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [AccountTypeID]
	,[AccountType]
	,[AccountNumber]
	,ISNULL(at.[Description],'') Description
	,at.[AccountGroupID]
	,AccountGroup		
	,MainAccountType		
	,ISNULL(at.[TransactionTypeID],0) TransactionTypeID
	,ISNULL(tt.[TransactionType],'PAY/REC') TransactionType
	,CASE WHEN at.[ShowInUI] = 1 THEN 'Yes' ELSE  'No' END  ShowInUI
	FROM [account].[MainAccountType] mat
	INNER JOIN [account].[AccountGroup] ag ON mat.MainAccountTypeID = ag.MainAccountTypeID
	INNER JOIN [account].[AccountType] at ON ag.AccountGroupID = at.AccountGroupID
	LEFT JOIN [account].[TransactionType] tt ON at.TransactionTypeID = tt.TransactionTypeID
	ORDER BY [AccountNumber]
END







