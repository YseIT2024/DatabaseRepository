

CREATE FUNCTION [account].[fnGetTransactionDescription]
(
	@TransactionTypeID INT,
	@AccountTypeID INT,
	@ActualAmount DECIMAL(18,6),
	@ActualCurrencyID INT,	
	@Remarks VARCHAR(MAX) = ''
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @AccountType varchar(100);
	DECLARE @TransactionType varchar(5);
	DECLARE @TransactionFactor int;
	DECLARE @Currency varchar(5);

	SELECT @TransactionType = tt.TransactionType
	,@TransactionFactor = tt.TransactionFactor
	FROM account.TransactionType tt			
	WHERE tt.TransactionTypeID = @TransactionTypeID 

	SELECT @AccountType = act.AccountType
	FROM account.AccountType act
	WHERE act.AccountTypeID = @AccountTypeID

	SELECT @Currency = c.CurrencySymbol
	FROM currency.Currency c
	WHERE c.CurrencyID = @ActualCurrencyID

	IF(@TransactionFactor < 0)
		BEGIN
			SET @TransactionType = 'PAY';
		END
	ELSE
		BEGIN
			SET @TransactionType = 'REC';
		END

	IF(LEN(@Remarks) > 0)
	BEGIN
		SET @Remarks = ', ' + @Remarks;
	END

	SET @Remarks = (@TransactionType + ': ' + @Currency + CAST(CAST(ABS(@ActualAmount) as decimal(18,2)) as varchar(15)) + ', ' + @AccountType + @Remarks);

	RETURN @Remarks
END

