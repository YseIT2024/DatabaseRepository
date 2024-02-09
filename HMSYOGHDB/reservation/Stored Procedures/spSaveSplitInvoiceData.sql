CREATE PROCEDURE [reservation].[spSaveSplitInvoiceData] 
  (
	@FolioNumber int,
	@GuestID int =null,
	@GRCNo nvarchar(30)=null,
	@GSTIN nvarchar(30)=null,
	@TotalAmountBeforeTax decimal(18,2),
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
	@MainInvoiceNo int,
	@BillTo int,
	@SplitInvoiceServices as [reservation].[SplitInvoiceDetails] readonly
  )
AS

SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @InvoiceNo int;
	DECLARE @InvoiceNumber nvarchar(150)


	DECLARE @IsComplimentary bit
	DECLARE @ComplimentaryPercentage decimal(18,2)

BEGIN

BEGIN TRY	

			BEGIN
			BEGIN TRANSACTION	
			
			SET @InvoiceNumber=(SELECT ProformaInvoiceNo FROM reservation.ProformaInvoice where ReservationId=(select ReservationID from reservation.Reservation where FolioNumber=@FolioNumber) and DocumentTypeId=2)
				IF((select COUNT(*) from reservation.Invoice where FolioNumber=@FolioNumber)>=1)
				BEGIN
				DECLARE @INO int=(select COUNT(*) from reservation.Invoice where FolioNumber=@FolioNumber)-1+1
					SET @InvoiceNumber = @InvoiceNumber+'-'+ CONVERT(NVARCHAR,(@INO));
				END

				--SET @IsComplimentary =(SELECT * FROM reservation.InvoiceDetails where InvoiceNo=@MainInvoiceNo and )

			 -- Insert Query
						INSERT INTO [reservation].[Invoice]
							   ([InvoiceDate],[FolioNumber],[GuestID],[GRCNo],
							   [GSTIN],[TotalAmountBeforeTax],[VatAmount],[ServiceTaxAmount],
							   [TotalAmountAfterTax],[AdditionalDiscount],[RoundOffAmount],[TotalAmountNet]
							   ,[InvoiceStatus],[PrintStatus],[Remarks],[CreatedBy],[Createdon],[BillToType],[ParentInvoiceNo],[Billto],[InvoiceNumber])
						 VALUES
							   (getdate(), @FolioNumber ,@GuestID ,@GRCNo ,
									@GSTIN ,@TotalAmountBeforeTax ,@VatAmount ,@ServiceTaxAmount ,
									@TotalAmountAfterTax ,@AdditionalDiscount ,	@RoundOffAmount ,@TotalAmountNet ,
									1 ,0 ,'Invoice Generated' ,@UserID ,getdate(),@BillToType,@MainInvoiceNo,@BillTo,@InvoiceNumber)		

						SET @InvoiceNo = SCOPE_IDENTITY();
						
						INSERT INTO [reservation].[InvoiceDetails] (
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
							,[BillingCode]
							,IsComplimentary	
							,ComplimentaryPercentage
						)
						SELECT @InvoiceNo,si.TransDate,si.ItemId,si.ItemDescription,NULL,si.Rate,si.Quantity,si.TaxId,si.TaxPercentage,
						si.Rate,si.TaxAmount,si.Amount,NULL ,
						(select distinct BillingCode from [reservation].[InvoiceDetails] where ServiceId=si.ItemId and InvoiceNo= @MainInvoiceNo) 						
						--id.BillingCode
						,(select distinct IsComplimentary from [reservation].[InvoiceDetails] where ServiceId=si.ItemId and InvoiceNo= @MainInvoiceNo)
						,(select distinct ComplimentaryPercentage from [reservation].[InvoiceDetails] where ServiceId=si.ItemId and InvoiceNo= @MainInvoiceNo)
						FROM @SplitInvoiceServices si
						--INNER join [reservation].[InvoiceDetails] id on si.ItemId=id.ServiceId 
						--INNER join [service].[Item] st on si.itemid=st.ItemID 
						where Amount>0


			SET @IsSuccess = 1; --success
			SET @Message = 'created successfully '
		COMMIT TRANSACTION	
		END
 
-- select * from [reservation].[InvoiceDetails] where InvoiceNo in (25)
		 


	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
		END;  
		
		---------------------------- Insert into activity log---------------	
		--DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		 
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END