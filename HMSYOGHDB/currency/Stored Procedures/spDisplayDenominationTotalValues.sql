



CREATE PROCEDURE [currency].[spDisplayDenominationTotalValues] -- 1,2
	(
		@DrawerID int,
		@DenominationTypeId int
	)
AS
BEGIN
	
	Declare @AccountingDateId int
	
			Select @AccountingDateId = [account].[GetAccountingDateIsActive](@DrawerID)
			 

		if(@AccountingDateId=null)
			Begin
				Select 'Accounting date is closed, Please open new Accounting date than try again' As ErrorMessage
				return
			End
        
	SELECT   [currency].[DenominationStatistics].DenominationStatisticsId, [currency].[DenominationStatistics].DenomQuantity Quantity, 
	[currency].[Denomination].DenominationValue  , [currency].[DenominationStatistics].DenomTotalValue, [currency].[DenominationType].CurrencyId
	FROM        [currency].[DenominationStatistics]   
	INNER JOIN
	 [currency].[Denomination] ON   [currency].[DenominationStatistics].DenominationId = [currency].[Denomination].DenominationId
	INNER JOIN
	[currency].[DenominationType] ON [currency].[Denomination].DenominationTypeId = [currency].[DenominationType].DenominationTypeId

	WHERE        ([currency].[Denomination].IsActive = 1) AND ([currency].[Denomination].DenominationTypeId = @DenominationTypeId) AND 
	( [currency].[DenominationStatistics].AccountingDateId = @AccountingDateId) AND ([currency].[DenominationStatistics].DrawerID = @DrawerID)
	Order by [currency].[Denomination].DenominationValue desc

		
END














