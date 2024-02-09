
CREATE PROCEDURE [report].[spGetCasinoAndHotelCashFigure] --1,1
(
	@DrawerID int,
	@UserId int,
	@AccountingDate Date = NULL
)
AS
BEGIN	
	Declare @AccountingDateId int;	
	Declare @LocationID int =
	(
		SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID
	);

	IF (@AccountingDate IS NULL)
		BEGIN
			SELECT @AccountingDateId = ad.AccountingDateId, @AccountingDate = ad.AccountingDate
			FROM [account].[AccountingDates] ad   
			WHERE ad.DrawerID = @DrawerID AND ad.IsActive = 1
		END
	ELSE
		BEGIN
			SELECT @AccountingDateId = ad.AccountingDateId
			FROM [account].[AccountingDates] ad    
			WHERE ad.DrawerID = @DrawerID AND ad.AccountingDate = @AccountingDate
		END

	SELECT dvt.DenominationValueTypeID, dvt.DenominationValueType, d.DenominationTypeID,  dt.DenominationType, ds.DenominationID, 
	d.DenominationValue [Denomination], ds.DenomQuantity [Quantity], ds.DenomTotalValue [DenomTotal], [CurrencySymbol]
	FROM currency.DenominationValueType dvt
	INNER JOIN currency.DenominationType dt ON dvt.DenominationValueTypeID = dt.DenominationValueTypeID
	INNER JOIN currency.Denomination d ON dt.DenominationTypeID = d.DenominationTypeID
	INNER JOIN currency.DenominationStatistics ds ON d.DenominationID = ds.DenominationID
	INNER JOIN currency.Currency c ON dt.CurrencyID = c.CurrencyID
	WHERE ds.DrawerID = @DrawerID AND ds .AccountingDateId = @AccountingDateId
	ORDER BY dvt.DenominationValueTypeID, d.DenominationTypeID, ds.DenominationID

	EXEC [report].[spGetCasinoOrHotelCashFigureSummary] NULL, @DrawerID, @AccountingDateId

	SELECT FORMAT(GETDATE(), 'dd-MMM-yyyy hh:mm tt') [Date], FORMAT(@AccountingDate,'dd-MMM-yyyy') [AccountingDate]

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Casino And Hotel Cashfigure', @UserID
END

