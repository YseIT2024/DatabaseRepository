 CREATE PROCEDURE [currency].[currencyExchangeRatetrns]
(
@MainCurrencyID int,
@CurrencyID int ,
@Rate decimal(12, 6),
@AccountingDate datetime,
@UserID int,
@LocationID int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
		DECLARE @CurID int=@CurrencyID;
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	
	DECLARE @ProcessTypeId INT;
	DECLARE @ToUserId INT;
	DECLARE @CrTanID INT;

	DECLARE @Description nvarchar(max) = '';	
	DECLARE @OldRate nvarchar(100);
	DECLARE @NewRate nvarchar(100);
	DECLARE @AUTOAPPROVAL_USERID INT=88;
	DECLARE @ValidUser INT=0;

		IF(@UserID=88)
		BEGIN
			SET @ValidUser=1
		END
		
		IF(@UserID=87)
		BEGIN
			SET @ValidUser=1
		END

		IF(@ValidUser=1)
			BEGIN
				BEGIN TRY		
				BEGIN TRANSACTION	
		
		
	
		
		

				IF(EXISTS(SELECT [CurrencyID] FROM [currency].[ExchangeRate] WHERE [MainCurrencyID]= @MainCurrencyID 
				AND [CurrencyID] = @CurrencyID AND [AccountingDate] = @AccountingDate))
					BEGIN

					SET @Message = 'Exchange Rate is already exist for selected Currency and Accounting Date';
					SET @IsSuccess = 0;

					END
				ELSE
					BEGIN

						INSERT INTO [currency].[ExchangeRate]
						([MainCurrencyID],[CurrencyID],[Rate],[AccountingDate],[CreatedBy],[CreatedDate],[AuthorizedFlag])
						VALUES(@MainCurrencyID,@CurrencyID,@Rate,@AccountingDate,@UserID,GETDATE(),0)


				--if(@UserID=@AUTOAPPROVAL_USERID)
				--begin
				--INSERT INTO [currency].[ExchangeRate]
				--					([MainCurrencyID],[CurrencyID],[Rate],[AccountingDate],[CreatedBy],[CreatedDate],[AuthorizedFlag])
				--					VALUES(@MainCurrencyID,@CurrencyID,@Rate,@AccountingDate,@UserID,GETDATE(),0)
				--end
				--else
				--begin
				--INSERT INTO [currency].[ExchangeRate]
				--					([MainCurrencyID],[CurrencyID],[Rate],[AccountingDate],[CreatedBy],[CreatedDate],[AuthorizedFlag])
				--					VALUES(@MainCurrencyID,@CurrencyID,@Rate,@AccountingDate,@UserID,GETDATE(),1)
				--end
						SET @CrTanID = SCOPE_IDENTITY();	-- For Approval workflow

						update [currency].[ExchangeRateHistory] set oldrate=NewRate, NewRate=@Rate where CurrencyID=@CurrencyID
						 
						SET @Message = 'New Exchange Rate added.';
						SET @IsSuccess = 1; --success

						SET @Title = 'Exchange Rate: ' + 'New Exchange Rate:'+ STR(@Rate) + ' added for MainCurrencyID: '+ STR(@MainCurrencyID) + 
						' and CurrencyID:' + STR (@CurrencyID)
						SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					
						EXEC [app].[spInsertActivityLog]9,@LocationID,@Title,@UserID


						--- Insert Approval WorkFlow
						SET @ProcessTypeId=3;
						SET @ToUserId=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId ORDER BY ApprovalLevel ASC)
								
						set @OldRate= (select top(1) CONVERT(NVARCHAR, OldRate, 0)from [currency].[ExchangeRateHistory] where CurrencyID=@CurID);
						set @Description  = (select  CurrencyCode from currency.Currency where CurrencyID=@CurID)+' Currency Exchange Rate Changed, From Rate '+ CONVERT(NVARCHAR, @OldRate , 0)+' and To Rate '+ CONVERT(NVARCHAR, @Rate, 0)+''

						if(@ValidUser=1)
						begin
						EXEC [reservation].[spCreateUpdateAppravalForTransaction]@ProcessTypeId, @LocationID, @UserID, @CrTanID, 1, NULL, NULL, @ToUserId,NULL, @Description,@OldRate,@Rate
						end
						else
						begin
						EXEC [reservation].[spCreateUpdateAppravalForTransaction]@ProcessTypeId, @LocationID, @UserID, @CrTanID, 0, NULL, NULL, @ToUserId,NULL, @Description,@OldRate,@Rate
						end
								
						--- Insert Approval WorkFlow End - @ProcessTypeId, @LocationID, @UserID, @CurrencID, Status, ModifiedOn, ModifiedBy, @ToUserId, Remark,DESCRIPTION , OLD Price , New Price ,Is Approval Visible
					
				END
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

				--IF(@LocationID = 0)
				--	BEGIN 
				--		SET @Message = 'New Location has been added successfully.';
				--	END
				--ELSE
				--	BEGIN
				--		SET @Message = 'Location has been updated successfully.';
				--	END
				END;  
		
				--------------Insert into activity log----------------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]9,@LocationID,@Act,@UserID	
				END CATCH;  
			END
		ELSE
			BEGIN
				SET @Message = 'Sorry, you do not have the necessary permissions to create an exchange rate.';
				SET @IsSuccess = 0;
			END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END