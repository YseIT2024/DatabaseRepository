
CREATE PROC [Housekeeping].[usp_HKMinibarOrder_IU]
           --@LedgerId int=null,
		   @OrderId int =0,           
           @FolioNumber int,
           @GuestID int=NULL, 
           @RoomNo int=NULL, 
           @TotalAmountBeforeTax decimal(18,6),
           @Discount decimal(18,6),
           @ServiceCharge decimal(18,6),
           @TaxAmount decimal(18,6),
           @TotalAmountAfterTax decimal(18,6),
           @CashPaid decimal(18,6),
           @PINPaid decimal(18,6),
           @ReturnAmount decimal(18,6),
           @OrderStatus int =NULL,
           @PrintStatus int =NULL,
           @Remarks varchar(250) =NULL,   
           @IsExpress bit,
           @ItemCount int=NULL,
           @IsActive bit =NULL,
           @userId int=NULL,   
           @LocationID int=NULL,			
           @MinibarOrderDetails AS [Housekeeping].[dtHKMinibarOrderDetails] READONLY,
           @ServiceTypeId int=null
AS 

BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	DECLARE @TaxId int = (SELECT  TaxID  FROM service.ServiceTax WHERE ServiceTypeID=61 and IsActive=1)
	DECLARE @TaxPer decimal(8, 2) = (SELECT TaxRate FROM general.Tax WHERE TaxID=@TaxId and IsActive=1)
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ContactID int;	
	DECLARE @ReservationID int = 0;	
	DECLARE @DiscountID int = NULL;	
	DECLARE @RoomID int;	

	--DECLARE @FolioNumber int;
	DECLARE @OutPutMSG varchar(500);
	DECLARE @OrdereDate datetime =GETDATE();
	
	DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);		

	DECLARE @Ledger_TotalAmountBeforeTax decimal(6,2);
		
	set @Ledger_TotalAmountBeforeTax=@TotalAmountBeforeTax-((@TaxPer/100)*@TotalAmountBeforeTax); 
	--set @TotalAmountBeforeTax=@TotalAmountAfterTax-@TaxAmount ----Added by Arabinda on 26/07/2023 
DECLARE @OrderDetailId int;
DECLARE @ItemID int;

	BEGIN TRY		
		BEGIN TRANSACTION							
					IF(@OrderId=0)
						BEGIN	
						
						INSERT INTO [Housekeeping].[HKMinibarOrder]
							([OrdereDate],[FolioNumber],[GuestID],[RoomNo]
							,[TotalAmountBeforeTax],[Discount],[ServiceCharge],[TaxAmount]
							,[TotalAmountAfterTax],[CashPaid],[PINPaid],[ReturnAmount]
							,[OrderStatus],[PrintStatus],[Remarks],[CreatedBy]
							,[Createdon],[ItemCount],[IsActive],[IsExpress],[ServiceTypeId])
						VALUES
							(GETDATE(), @FolioNumber, @GuestID, @RoomNo
							,@TotalAmountBeforeTax 							
							,@Discount, @ServiceCharge, @TaxAmount 
							,@TotalAmountAfterTax, @CashPaid, @PINPaid, @ReturnAmount 
							,@OrderStatus, @PrintStatus, @Remarks, @userId 
							,getdate(),@ItemCount,@IsActive,@IsExpress,@ServiceTypeId)
									
						SET @OrderId = SCOPE_IDENTITY();

						INSERT INTO [Housekeeping].[HKMinibarOrderDetails]
									([OrderId],[ItemId],[Quantity],[Rate],[TaxId],[TaxPer],[ServiceCharge],[TotalAmountAfterTax],
									[Remarks],[CreatedBy],[CreatedOn],[IsActive],[LineTaxAmt],[TotalAmountBeforeTax])									
							  select @OrderId,ItemID,[Quantity],[ItemRate],[TaxId],[TaxPercent],@ServiceCharge,TotalAmount,--+TotalAmount*(TaxPercent/100),
							  [Remarks],@userId,getdate(),@IsActive,(TotalAmount*TaxPercent/(TaxPercent+100)),TotalAmount-(TotalAmount*TaxPercent/(TaxPercent+100))--TotalAmount*(TaxPercent/100),TotalAmount						
							from @MinibarOrderDetails
						--INSERT INTO [Housekeeping].[HKMinibarOrderDetails]
						--			([OrderId],[ItemId],[Quantity],[Rate],[TaxId],[TaxPer],[ServiceCharge],[TotalAmountAfterTax],
						--			[Remarks],[CreatedBy],[CreatedOn],[IsActive],[LineTaxAmt],[TotalAmountBeforeTax])									
						--	  select @OrderId,ItemID,[Quantity],[ItemRate],[TaxId],[TaxPercent],@ServiceCharge,TotalAmount,
						--	  [Remarks],@userId,getdate(),@IsActive,TotalAmount/(1+TaxPercent),TotalAmount-(TotalAmount/(1+TaxPercent))						
						--	from @MinibarOrderDetails

							--SET @OrderDetailId = SCOPE_IDENTITY();

							DECLARE OrderDetailsCursor CURSOR FOR
							SELECT OrderDetailId,ItemId,TotalAmountBeforeTax,TaxId,TaxPer,TotalAmountAfterTax,Remarks,IsActive
							FROM [Housekeeping].[HKMinibarOrderDetails] 
							WHERE OrderId = @OrderId;

						OPEN OrderDetailsCursor;

					-- Fetch the first record
					FETCH NEXT FROM OrderDetailsCursor INTO @OrderDetailId, @ItemID,@TotalAmountBeforeTax, @TaxId, @TaxPer,@TotalAmountAfterTax,@Remarks,@IsActive;
					
					-- Loop through the records
					WHILE @@FETCH_STATUS = 0
					BEGIN
					SET @Remarks=(select Name from service.Item where ItemID=@ItemID)
					SET @Remarks='Service-Item Name:' + @Remarks  + ' ,Order Ref#:'+STR(@OrderId)
						-- Execute [reservation].[usp_GuestFolioDetails_IU] for each record
						EXEC [reservation].[usp_GuestFolioDetails_IU]
							@FolioNumber = @FolioNumber,
							@ServiceId = @ServiceTypeId,
							@Transrefno = @OrderDetailId,
							@AmtBeforeTax = @TotalAmountBeforeTax,
							@taxId = @TaxId,
							@taxper = @TaxPer,
							@AmtAfterTax = @TotalAmountAfterTax,
							@PaidStatus = 1,
							@TransStatus = 1,
							@Remarks = @Remarks,
							@IsActive = @IsActive,
							@LocationID = @LocationID,
							@userId = @userId;

						-- Fetch the next record
						 FETCH NEXT FROM OrderDetailsCursor INTO @OrderDetailId,@ItemID, @TotalAmountBeforeTax, @TaxId, @TaxPer, @TotalAmountAfterTax, @Remarks, @IsActive;
					END

					-- Close and deallocate the cursor
					CLOSE OrderDetailsCursor;
					DEALLOCATE OrderDetailsCursor;
							

						--EXEC [reservation].[usp_GuestFolioDetails_IU]
						   
						--	@FolioNumber= @FolioNumber,	
						--	@ServiceId =@ServiceTypeId,
						--	@Transrefno=@OrderId , 
						--	@AmtBeforeTax = @Ledger_TotalAmountBeforeTax,   
						--	@taxId =@TaxId,
						--	@taxper =@TaxPer,
						--	@AmtAfterTax =@TotalAmountBeforeTax,
						--	@PaidStatus= 1,
						--	@TransStatus =1,
						--	@Remarks =@Remarks,
						--	@IsActive =@IsActive,	
						--	@LocationID =@LocationID,
						--	@userId =@userId


						SET @IsSuccess = 1; --success
						SET @Message = 'New Order has been created successfully'

						END
					ELSE
						BEGIN
							UPDATE [Housekeeping].[HKMinibarOrder]
							SET 
							OrderStatus=@OrderStatus,
							ModifiedOn=GETDATE(),
							ModifiedBy=@userId,
							IsActive='False'						
							WHERE OrdereDate=@OrderId

							----To cancell in Foliodetails-----

							------------End-------------------
						
						END											
					
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

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumber AS [FolioNumber],@ReservationID as [ReservationID],@OrderId AS [OrderId]
END
