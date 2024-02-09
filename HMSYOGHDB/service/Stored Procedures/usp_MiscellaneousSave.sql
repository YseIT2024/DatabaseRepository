
create PROC [service].[usp_MiscellaneousSave]		              
           @FolioNumber int,
           @GuestID int=NULL, 
           @RoomNo int=NULL, 
		   @InvoiceDate datetime,
           @Discount decimal(6,2),
           @ServiceCharge decimal(6,2),
           @TaxAmount decimal(6,2),
           @TotalAmountAfterTax decimal(6,2),
           @CashPaid decimal(6,2),
           @PINPaid decimal(6,2),
           @ReturnAmount decimal(6,2),
           @InvoiceStatus int =NULL,
           @PrintStatus int =NULL,
           @Remarks varchar(250) =NULL, 
           @ItemCount int=NULL,
           @IsActive bit =NULL,
		   @userId int,   
		   @LocationID int=NULL,
		   @MiscellaneousSalesDetails AS [service].[dtMiscellaneousSalesDetails] READONLY
AS 

BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	--DECLARE @ContactID int;	
	--DECLARE @ReservationID int = 0;	
	--DECLARE @DiscountID int = NULL;	
	--DECLARE @RoomID int;	
	DECLARE @InvoiceNo int;
	DECLARE @OutPutMSG varchar(500);
	--DECLARE @OrdereDate datetime =GETDATE();
	
	DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);		

	BEGIN TRY		
		BEGIN TRANSACTION							
					
						BEGIN	
						INSERT INTO [Housekeeping].[HKMISCInvoice]
								(FolioNumber,GuestID,RoomNo,InvoiceDate,Discount,ServiceCharge,TaxAmount
								,TotalAmountAfterTax,CashPaid,PINPaid,ReturnAmount,InvoiceStatus,PrintStatus,Remarks,CreatedBy
								,Createdon, ItemCount,IsActive)
							VALUES
								(@FolioNumber,@GuestID,@RoomNo,@InvoiceDate,@Discount,@ServiceCharge,@TaxAmount
								,@TotalAmountAfterTax,@CashPaid,@PINPaid,@ReturnAmount,@InvoiceStatus,@PrintStatus,@Remarks,@userId  
								, getdate(),@ItemCount,@IsActive)
									
						SET @InvoiceNo = SCOPE_IDENTITY();

						INSERT INTO [Housekeeping].[HKMISCInvoiceDetails]
									([InvoiceNo],[ItemDescription],[Quantity],[Rate],[TaxPer],[TotalRate], [CreatedBy], [Createdon], [IsActive])
						select @InvoiceNo,ItemDescription,Quantity ,Rate ,Tax,TotalRate,@userId, GETDATE(),1		 						
						from @MiscellaneousSalesDetails


						SET @IsSuccess = 1; --success
						SET @Message = 'Miscellaneous Item/s are created successfully '

						END
											
																	
					----	DECLARE @NotDesc varchar(max) = @Title + ' at ' + @LocationCode + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
									
					----	EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
						
					----END	
		COMMIT TRANSACTION					
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			SET @FolioNumber = -1; --error
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumber AS [FolioNumber], @InvoiceNo AS [InvoiceNo] 
END


