CREATE PROCEDURE [currency].[spUpdateTillDenominationStatistics]
(  
	@DrawerID  int,  
	@DenominationStatisticsDetails [currency].[dtDenominationStatisticsDetails]  readonly, 
	@UserID int 
)  
AS  
BEGIN  
	SET XACT_ABORT ON;  
	
	Declare @IsSuccess bit = 0;
	Declare @Message varchar(max) = '';	
	Declare @RowCount int;  
	Declare @RowID int = 1;    
	Declare @AccountingDateId int;
	Declare @LocationID int=(Select LocationID From app.Drawer Where DrawerID=@DrawerID);
	Declare @Quantity int = 0;
	Declare @DenominationTotalValue decimal(18,4) = 0.0000;   
	Declare @DenominationTotalMainCurrencyValue decimal(18,4) = 0.0000; 
	Declare @DenominationStatisticsId int;  
	Declare @CurrencyId int;  
	Declare @DenominationValue decimal(18,4);
	Declare @CurrencyRateMain decimal(18,4) = 0.0000;

	BEGIN TRY  
		Select @AccountingDateId = [account].[GetAccountingDateIsActive](@DrawerID); 

		if(@AccountingDateId=null)  
			Begin  
				Select 'The accounting date is already closed. Please open a new accounting date to continue.' As ErrorMessage  
				return  
			End  

			Select @RowCount = Count(*) From @DenominationStatisticsDetails  
						
			BEGIN TRANSACTION
				While(@RowCount >= @RowID)  
					Begin  
						Set @Quantity = 0  
						Set @DenominationTotalValue = 0.0000  
						Set @DenominationValue = 0.0000 

						Select @DenominationStatisticsId = DenominationStatisticsId, 
						@Quantity = DenomQuantity, 
						@DenominationTotalValue = DenomTotalValue,
						@DenominationValue = DenominationTotalMainCurrencyValue, 
						@CurrencyId = CurrencyID   
						From @DenominationStatisticsDetails 
						Where ID = @RowID  
  
						Select @CurrencyRateMain = 
						(SELECT ExchangeRate FROM [currency].[vwCurrentExchangeRate] Where DrawerID = @DrawerID AND CurrencyID = @CurrencyId ) 
  
						Set @DenominationTotalMainCurrencyValue = (@DenominationValue *@Quantity) / @CurrencyRateMain; 
  
						UPDATE [currency].[DenominationStatistics]
						SET DenomQuantity = @Quantity, 
						DenomTotalValue = (@DenominationValue * @Quantity),
						DenominationTotalMainCurrencyValue = @DenominationTotalMainCurrencyValue  
						WHERE (DenominationStatisticsID = @DenominationStatisticsId)  
      
						Set @RowID = @RowID + 1  
					End  

				SET @IsSuccess = 1; --success
				SET @Message = 'Data successfully updated.'
			COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = 'Data successfully updated.'
		END;  
		
		---------------------------- Insert into activity log---------------	
		Declare @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS IsSuccess, @Message as [Message]
END


