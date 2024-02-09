-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
Create PROCEDURE [app].[spGetCurrencyExchangeRateData_BK] 
	(
	 @MainCurrencyID int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 

     SELECT exRate.[MainCurrencyID],exRate.[CurrencyID],exRate.[Rate], 
	-- convert(varchar,exRate.[AccountingDate], 106) AccountingDate,
	--  exRate.[AccountingDate] 
	 CreatedDate as  AccountingDate,
	 
	 cur.[CurrencyCode],

	 CASE WHEN AuthorizedFlag=1 THEN 'Pending'
	 WHEN AuthorizedFlag=0 THEN 'Approved'
	 ELSE '' END AS ApprovalStatus,
	  CreatedDate
	 FROM  [currency].[ExchangeRate] exRate
	 INNER JOIN [currency].[Currency] cur ON exRate.CurrencyID = cur.CurrencyID
	  WHERE exRate.[MainCurrencyID] =  @MainCurrencyID order by exRate.ID DESC  

	 SELECT [AccountingDateId] AS AccountingDateID, 
	 --convert(varchar,[AccountingDate], 106) AS AccountingDate
	  convert(varchar,[AccountingDate], 106) +' '+FORMAT(GETDATE(),'hh:mm:ss') AS AccountingDate 
        FROM [Account].[AccountingDates] where convert(varchar,[AccountingDate], 106)=CONVERT(varchar ,GETDATE(), 106)
       -- ORDER BY [AccountingDateId] DESC;

	 --SELECT [AccountingDateId] AccountingDateID, convert(varchar,[AccountingDate], 106) AccountingDate
  --   FROM  [Account].[AccountingDates] WHERE [IsActive] = 1

	SELECT [CurrencyID],[CurrencyCode]	 FROM  [currency].[Currency] WHERE [IsMain] = 0
END


