
CREATE PROCEDURE [reservation].[spCreateProvisionalInvoice](		
	@FolioNumber int,
	@GuestID int =null,
	@GRCNo nvarchar(30),
	@GSTIN nvarchar(30),
	@TotalAmountBeforeTax decimal(18,2) ,
	@VatAmount decimal(18,2)=null ,
	@ServiceTaxAmount decimal(18,2)=null ,
	@TotalAmountAfterTax decimal(18,4)=null,
	@AdditionalDiscount decimal(18,4)=null,
	@RoundOffAmount decimal(18,4) ,
	@TotalAmountNet decimal(18,4),
	@InvoiceStatus int=null ,
	@PrintStatus int=null ,
	@Remarks nvarchar(100) =null,
	@UserID int,	
	@LocationID int	,
	@BillToType nvarchar(150)=null,
	@TotalReceived decimal(18,2)=null,
	@Balance decimal(18,2)=null,
	@dtInvoiceDetails AS [reservation].[InvoiceDetails] READONLY
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @InvoiceNo int;

	BEGIN TRY	
		if @GuestID is null 
			begin
				SELECT @GuestID=GuestId FROM RESERVATION.Reservation where FolioNumber=@FolioNumber
			end

		delete from [reservation].[ProvisionalInvoice]
		delete from  [reservation].[ProvisionalInvoiceDetails]


		IF NOT EXISTS (SELECT * FROM [reservation].[ProvisionalInvoice] where FolioNumber=@FolioNumber )--If Invoice  available
			BEGIN
				BEGIN TRANSACTION		
						INSERT INTO [reservation].[ProvisionalInvoice]
							   ([InvoiceDate],[FolioNumber],[GuestID],[GRCNo],
							   [GSTIN],[TotalAmountBeforeTax],[VatAmount],[ServiceTaxAmount],
							   [TotalAmountAfterTax],[AdditionalDiscount],[RoundOffAmount],[TotalAmountNet]
							   ,[InvoiceStatus],[PrintStatus],[Remarks],[CreatedBy],[Createdon],[BillToType],[TotalReceived],[Balance])
						 VALUES
							   (getdate(), @FolioNumber ,@GuestID ,@GRCNo ,
									@GSTIN ,@TotalAmountBeforeTax ,@VatAmount ,@ServiceTaxAmount ,
									@TotalAmountAfterTax ,@AdditionalDiscount ,	@RoundOffAmount ,@TotalAmountNet ,
									1 ,0 ,'Provisional Invoice Generated' ,@UserID ,getdate(),@BillToType,@TotalReceived,@Balance)		

						SET @InvoiceNo = SCOPE_IDENTITY();


						INSERT INTO [reservation].[ProvisionalInvoiceDetails] (
							 [InvoiceNo]
							,[TransactionDate]
							,[ServiceId]
							,[ServiceDescription]
							,[SACNo]
							,[ServiceRate]
							,[ServiceQty]
							,[TaxId]
							,[TaxPercent]
							,[AmountBeforeTax]
							,[TaxAmount]
							,[AmountAfterTax]
							,[DisplaySequence]
						)
						SELECT @InvoiceNo,TransDate,ItemId,ItemDescription,NULL,Rate,Quantity,TaxId,TaxPercentage,Rate,TaxAmount,Amount,NULL FROM @dtInvoiceDetails

					SET @IsSuccess = 1; 				
				SET @Message = 'Provisional Invoice created for ' + ltrim(str(@FolioNumber)) ;
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				SET @IsSuccess = 0; 				
				SET @Message = 'Provisional Invoice already exisits for ' + ltrim(str(@FolioNumber)) ;
			END
	
	
	
	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			--SET @FolioNumbers = -1; --error
		END;    
		
		--IF (XACT_STATE() = 1)  
		--BEGIN  			
		--	COMMIT TRANSACTION;   
		--	SET @IsSuccess = 1; --success  
		--	SET @Message = 'Invoice has been created successfully for ' + @FolioNumber;
		--END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		--EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumber AS [FolioNumber], @InvoiceNo As [InvoiceNo]
END



