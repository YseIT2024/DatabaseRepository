-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [reservation].[InsertCurrencyRate]
	
AS
BEGIN

	--DECLARE @RATECHANGECOUNT INT;
	--SELECT @RATECHANGECOUNT= COUNT(MainCurrencyId) FROM [currency].[ExchangeRate] WHERE FORMAT(ACCOUNTINGDATE,'yyyy-MM-dd')= FORMAT(GETDATE(),'yyyy-MM-dd') 
	--and AuthorizedFlag=0 and currencyid=2
	IF NOT EXISTS (SELECT CurrencyId FROM [currency].[ExchangeRate] WHERE FORMAT(ACCOUNTINGDATE,'yyyy-MM-dd')= FORMAT(GETDATE(),'yyyy-MM-dd') 
		and AuthorizedFlag=0 and currencyid=2)	
	BEGIN
		INSERT INTO [currency].[ExchangeRate]
		SELECT top 1 MainCurrencyId, CurrencyId, Rate,getdate(),CreatedBy, GETDATE(),AuthorizedFlag FROM [HMSYOGH].[currency].[ExchangeRate] WHERE FORMAT(ACCOUNTINGDATE,'yyyy-MM-dd')= FORMAT(GETDATE()-1,'yyyy-MM-dd') 
		and AuthorizedFlag=0 and currencyid in (2) order by createddate desc 
	END
	IF NOT EXISTS (SELECT CurrencyId FROM [currency].[ExchangeRate] WHERE FORMAT(ACCOUNTINGDATE,'yyyy-MM-dd')= FORMAT(GETDATE(),'yyyy-MM-dd') 
		and AuthorizedFlag=0 and currencyid=3)	
	BEGIN
		INSERT INTO [currency].[ExchangeRate]
		SELECT top 1 MainCurrencyId, CurrencyId, Rate,getdate(),CreatedBy, GETDATE(),AuthorizedFlag FROM [HMSYOGH].[currency].[ExchangeRate] WHERE FORMAT(ACCOUNTINGDATE,'yyyy-MM-dd')= FORMAT(GETDATE()-1,'yyyy-MM-dd') 
		and AuthorizedFlag=0 and currencyid in (3) order by createddate desc 
	END
	END