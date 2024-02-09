
CREATE PROCEDURE [app].[spGetCurrencyExchangeRateData] 
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
	   FORMAT(exRate.[AccountingDate],'dd-MMM-yyyy') as AccountingDate,
	 cur.[CurrencyCode],
	 (ISNULL(pt.Title, '') + ' ' + cd.FirstName + 
     CASE WHEN cd.LastName IS NULL THEN '' ELSE ' ' + cd.LastName END) AS [CreatedBy],
	 CASE WHEN AuthorizedFlag=1 THEN 'Pending'
	 WHEN AuthorizedFlag=0 THEN 'Approved'
	 ELSE '' END AS ApprovalStatus,
	 FORMAT(exRate.CreatedDate,'dd-MMM-yyyy hh:mm:ss') as CreatedDate
	 FROM  [currency].[ExchangeRate] exRate
	 INNER JOIN [currency].[Currency] cur ON exRate.CurrencyID = cur.CurrencyID
	 LEFT JOIN app.[User] u ON exRate.CreatedBy = u.UserID
     LEFT JOIN contact.Details cd ON u.ContactID = cd.ContactID
     LEFT JOIN person.Title pt ON cd.TitleID = pt.TitleID 
	 WHERE exRate.[MainCurrencyID] =  @MainCurrencyID order by exRate.ID DESC --

	 SELECT [AccountingDateId] AS AccountingDateID, 
	 --convert(varchar,[AccountingDate], 106) AS AccountingDate
	  convert(varchar,[AccountingDate], 106) +' '+FORMAT(GETDATE(),'hh:mm:ss') AS AccountingDate
        FROM [Account].[AccountingDates] where convert(varchar,[AccountingDate], 106)=CONVERT(varchar ,GETDATE(), 106)
       -- ORDER BY [AccountingDateId] DESC;

	 --SELECT [AccountingDateId] AccountingDateID, convert(varchar,[AccountingDate], 106) AccountingDate
  --   FROM  [Account].[AccountingDates] WHERE [IsActive] = 1

	SELECT [CurrencyID],[CurrencyCode]	 FROM  [currency].[Currency] WHERE [IsMain] = 0
END