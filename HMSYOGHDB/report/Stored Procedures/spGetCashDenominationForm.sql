
CREATE PROCEDURE [report].[spGetCashDenominationForm] --66
(
	@FundFlowID INT	
)
AS
BEGIN	
	DECLARE @AccountingDateId INT;	
	DECLARE @DrawerID INT;
	DECLARE @AccountingDate DATE;
	DECLARE @TransactionBy VARCHAR(50);
	DECLARE @SealBagNumber VARCHAR(50);
	DECLARE @ChangeInUSD DECIMAL(18,6) = 0;
	DECLARE @ChangeInSRD DECIMAL(18,6) = 0;
	DECLARE @ChangeInEUR DECIMAL(18,6) = 0;
	
	--SELECT @DrawerID = DrawerID, @AccountingDateId = AccountingDateID FROM fund.Flow
	--WHERE FundFlowID = @FundFlowID	
	
	--SELECT @AccountingDate = ad.AccountingDate
	--FROM [account].[AccountingDates] ad    
	--WHERE ad.DrawerID = @DrawerID AND ad.AccountingDateID = @AccountingDateId
	IF EXISTS(SELECT FundFlowID FROM fund.Flow WHERE ParentFundFlowID = @FundFlowID)
	BEGIN
		SELECT @ChangeInUSD = USDAmount, @ChangeInSRD = SRDAmount, @ChangeInEUR = EURAmount
		FROM fund.Flow WHERE ParentFundFlowID = @FundFlowID
	END
		
	SELECT 	FundFlowID	
	,ffd.FundFlowDirection
	,CASE WHEN ff.FundFlowDirectionID = 1 THEN fromHotel.LocationName ELSE fromCasino.CasinoName END [FromLocation]
	,CASE WHEN ff.FundFlowDirectionID = 1 THEN toCasino.CasinoName ELSE toHotel.LocationName END [ToLocation]	
	,ISNULL([SealbagNumber],'')[SealbagNumber]
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,[DateTime][DateTime]	
	,fs.FundFlowStatus
	,ISNULL(t.Title + ' ','') + cd.FirstName + ISNULL(' ' + cd.LastName,'') [TransferBy]
	,GETDATE() [PrintedOn]
	,@ChangeInUSD [ChangeInUSD]
	,@ChangeInSRD [ChangeInSRD]
	,@ChangeInEUR [ChangeInEUR] 
	FROM [fund].[Flow] ff
	INNER JOIN fund.[Type] ft ON ff.FundTypeID = ft.FundTypeID
	INNER JOIN fund.FundFlowDirection ffd ON ff.FundFlowDirectionID = ffd.FundFlowDirectionID
	INNER JOIN fund.FlowStatus fs ON ff.FundFlowStatusID = fs.FundFlowStatusID
	INNER JOIN account.AccountingDates ad ON ff.AccountingDateID = ad.AccountingDateId
	LEFT JOIN app.[User] u ON ff.UserID = u.UserID
	LEFT JOIN contact.Details cd ON u.ContactID = cd.ContactID
	LEFT JOIN person.Title t ON cd.TitleID = t.TitleID
	LEFT JOIN general.[Location] fromHotel ON ff.FlowFromID = fromHotel.LocationID
	LEFT JOIN company.Casino fromCasino ON ff.FlowFromID = fromCasino.CasinoID
	LEFT JOIN general.[Location] toHotel ON ff.FlowToID = toHotel.LocationID	
	LEFT JOIN company.Casino toCasino ON ff.FlowToID = toCasino.CasinoID
	WHERE ff.FundFlowID = @FundFlowID
	

	DECLARE @CDF TABLE(DenominationTypeID INT, DenominationType VARCHAR(20), DenominationID INT, 
	Denomination DECIMAL(18,2), Quantity INT, DenomTotal DECIMAL(18,2), CurrencySymbol VARCHAR(10))

	INSERT INTO @CDF(DenominationTypeID, DenominationType, DenominationID, Denomination, Quantity, DenomTotal, CurrencySymbol)
	SELECT  d.DenominationTypeID,  dt.DenominationType, ds.DenominationID, 
	d.DenominationValue [Denomination], ds.Quantity [Quantity], ds.TotalValue [DenomTotal], [CurrencySymbol]
	FROM currency.DenominationValueType dvt
	INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
	INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
	INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID
	LEFT JOIN fund.Denomination ds ON d.DenominationID = ds.DenominationID	
	WHERE ds.FundFlowID = @FundFlowID  AND dvt.DenominationValueTypeID = 2

	UNION ALL

	SELECT  d.DenominationTypeID,  dt.DenominationType, d.DenominationID, 
	d.DenominationValue [Denomination], 0 [Quantity], 0.00 [DenomTotal], [CurrencySymbol]
	FROM currency.DenominationValueType dvt
	INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
	INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
	INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID
	WHERE dvt.DenominationValueTypeID = 2

	SELECT DenominationTypeID, DenominationType, DenominationID, Denomination, SUM(Quantity) Quantity, SUM(DenomTotal) DenomTotal, CurrencySymbol 
	FROM @CDF
	GROUP BY DenominationTypeID, DenominationType, DenominationID, Denomination, CurrencySymbol
	ORDER BY DenominationTypeID	

END

