
create PROCEDURE [report].[spGetReconciliationSummary] 
(
	@AccountingDate DATE,
	@DrawerIDs as [app].[dtID] readonly
)
AS
BEGIN
	Declare @rowno int = 1;
	Declare @Drawer int;

	DECLARE @Reconciliation TABLE(AccountTypeId INT ,AccountType VARCHAR(100), [Debit(Pay)] DECIMAL(18,2), [Credit(Rec)] DECIMAL(18,2),Net DECIMAL(18,2));
	DECLARE @temp TABLE (ID INT IDENTITY(1,1),DrawerID INT);

	INSERT INTO @temp
	SELECT [ID] FROM @DrawerIDs

	WHILE(@rowno <= (SELECT COUNT(*) FROM @temp))
	Begin
	    SET @Drawer = (SELECT DrawerID FROM @temp WHERE ID = @rowno)			
		
		INSERT INTO	@Reconciliation
		(AccountTypeId ,AccountType, [Debit(Pay)], [Credit(Rec)], Net)
		EXEC [report].[spGetReconciliation] @AccountingDate,@Drawer	
				
		SET @rowno = @rowno + 1;
	End

	SELECT AccountType, SUM([Debit(Pay)]) [Debit(Pay)], SUM([Credit(Rec)]) [Credit(Rec)], SUM(Net) NET 
	FROM @Reconciliation
	GROUP BY AccountTypeId, AccountType
	ORDER BY AccountTypeId
END
