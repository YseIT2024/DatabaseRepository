
CREATE PROCEDURE [currency].[ClearCashFigureDenomQuantity]
(
	@DrawerID INT,
	@DenominationTypeID INT,
	@UserID INT 
)
AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @AccountingDateId INT;	
	DECLARE @LocationID INT = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	BEGIN TRY
		SELECT @AccountingDateId = AccountingDateId
		FROM account.AccountingDates 
		WHERE DrawerID = @DrawerID AND IsActive = 1

		UPDATE ds
		SET DenomQuantity = 0, 
		DenomTotalValue = 0,  
		DenominationTotalMainCurrencyValue = 0
		FROM [currency].[DenominationStatistics] ds 
		INNER JOIN currency.Denomination d ON ds.DenominationID = d.DenominationID
		INNER JOIN currency.DenominationType dt ON d.DenominationTypeID = dt.DenominationTypeID	
		WHERE ds.DrawerID = @DrawerID AND AccountingDateId = @AccountingDateId AND dt.DenominationTypeID = @DenominationTypeID

		SET @Message = 'Success';
		SET @IsSuccess = 1; --error	
	END TRY
	BEGIN CATCH	 
		SET @Message = ERROR_MESSAGE();
		SET @IsSuccess = 0; --error			
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

