
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [Housekeeping].[usp_HKLaundryOrder_IU]
			@OrderId int =0,           
           @FolioNumber int,
           @GuestID int=NULL, 
           @RoomNo int=NULL, 
           @TotalAmountBeforeTax decimal(6,2),
           @Discount decimal(6,2),
           @ServiceCharge decimal(6,2),
           @TaxAmount decimal(6,2),
           @TaxPer decimal(6,2),
           @TaxId int,
           @ExpresCharge decimal(6,2),
           @TotalAmountAfterTax decimal(6,2),
           @CashPaid decimal(6,2),
           @PINPaid decimal(6,2),
           @ReturnAmount decimal(6,2),
           @OrderStatus int =NULL,
           @PrintStatus int =NULL,
           @Remarks varchar(250) =NULL,   
           @IsExpress bit,
           @ItemCount int=NULL,
           @IsActive bit =NULL,
          @userId int=NULL,   
          @LocationID int=NULL,
          @LaundryType int,
         @LaundryOrderDetails AS [Housekeeping].[dtHKLaundryOrderDetails] READONLY
AS 

BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

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
	DECLARE @OrderDetailId int;
    DECLARE @ItemID int;
	DECLARE @Quantity int;
	DECLARE @Description varchar(500);

	BEGIN TRY		
		BEGIN TRANSACTION							
					IF(@OrderId=0)
						BEGIN	
						INSERT INTO [Housekeeping].[HKLaundryOrder]
								([OrdereDate],[FolioNumber],[GuestID]
								,[RoomNo],[TotalAmountBeforeTax],[Discount],[ServiceCharge]
								,[TaxAmount],[TotalAmountAfterTax],[CashPaid],[PINPaid]
								,[ReturnAmount],[OrderStatus],[PrintStatus],[Remarks]
								,[CreatedBy],[Createdon],[IsExpress],[ItemCount],[IsActive],[LaundryType])
							VALUES
								(@OrdereDate,@FolioNumber,@GuestID, 
								@RoomNo,@TotalAmountBeforeTax,@Discount,@ServiceCharge,
								@TaxAmount,@TotalAmountAfterTax,@CashPaid,@PINPaid,
								@ReturnAmount,@OrderStatus,@PrintStatus,@Remarks,   
								@userId, getdate(),@IsExpress,@ItemCount,@IsActive,@LaundryType)
									
						SET @OrderId = SCOPE_IDENTITY();
						INSERT INTO [Housekeeping].[HKLaundryOrderDetails]
									([OrderId],[ItemId],[Quantity],[Rate]
									,[RateClean],[RatePress],[RateRepair],[TaxId],[TaxPer]
									,[ExpresCharge],[ServiceCharge],[ReturnStatus],[Remarks]
									,[IsActive],[Clean],[Press],[Repair],[ItemRateChild],[Child],[CreatedBy],[Createdon],
									LineTotalTax,LineTotalBT,LineTotal) --LineTotalBT)--,LineTotalTax,	
						select @OrderId,ItemId,Quantity ,Rate ,
						[RateClean],[RatePress],[RateRepair],@TaxId,@TaxPer,	
						@ExpresCharge,0,0,@Remarks,
						1,Clean,Press,Repair,[ItemRateChild],[Child],@userId, GETDATE(),
						--([RateClean]+[RatePress]+[RateRepair])*(@TaxPer/100),----commented by sravani on 29-01-24
						Quantity*([RateClean]+[RatePress]+[RateRepair])*(@TaxPer/100),-------Added by sravani for reverse calculation
						--([RateClean]+[RatePress]+[RateRepair]),----commented by sravani on 29-01-24
						Quantity*([RateClean]+[RatePress]+[RateRepair]),------Added by sravani for reverse calculation
						--([RateClean]+[RatePress]+[RateRepair])+(([RateClean]+[RatePress]+[RateRepair])*(@TaxPer/100))	----commented by sravani on 29-01-24	
						Quantity*([RateClean]+[RatePress]+[RateRepair])+(Quantity*([RateClean]+[RatePress]+[RateRepair])*(@TaxPer/100))	------Added by sravani for reverse calculation	
						from @LaundryOrderDetails

						DECLARE OrderDetailsCursor CURSOR FOR
						SELECT OrderDetailId,ItemId,LineTotalBT,TaxId,TaxPer,LineTotal,Remarks,IsActive
						FROM [Housekeeping].[HKLaundryOrderDetails] 
						WHERE OrderId = @OrderId;

						OPEN OrderDetailsCursor;

					-- Fetch the first record
					FETCH NEXT FROM OrderDetailsCursor INTO @OrderDetailId, @ItemID,@TotalAmountBeforeTax, @TaxId, @TaxPer,@TotalAmountAfterTax,@Remarks,@IsActive;
					
					-- Loop through the records
					WHILE @@FETCH_STATUS = 0
					BEGIN
				      SET @Remarks=(select Name from service.Item where ItemID=@ItemID)
					  --SET @Quantity=(select Quantity from Housekeeping.HKLaundryOrderDetails where Ordeer=@ItemID)
					  --SET @OrderId=(select OrderId from Housekeeping.HKLaundryOrderDetails where ItemID=@ItemID)
					  --SET @Description = ('ItemName:' + STR(@Remarks) + 'Qty:' + STR(@Quantity) + 'Order Ref#:' + STR(@OrderId));					  SET @Remarks='Service-Item Name:' + @Remarks  + ' ,Order Ref#:'+STR(@OrderId)
					 
					  --(select Name from service.Item where ItemID=@ItemID) + 'Order Ref#:' + @OrderId

						------Modified By Arabinda on 26/07/2023 ------------------
						EXEC	 [reservation].[usp_GuestFolioDetails_IU]	
									--@LedgerId = 0,
							@FolioNumber = @FolioNumber,
							@ServiceId = 3,
							@Transrefno =@OrderDetailId,
							@AmtBeforeTax = @TotalAmountBeforeTax,
							@taxId = @TaxId,
							@taxper = @TaxPer,
							@AmtAfterTax = @TotalAmountAfterTax,
							@PaidStatus = 1,
							@TransStatus = 1,
							@Remarks = @Remarks,
							@IsActive = 1,
							@LocationID = @LocationID ,
							@userId = @userId

					FETCH NEXT FROM OrderDetailsCursor INTO @OrderDetailId,@ItemID, @TotalAmountBeforeTax, @TaxId, @TaxPer, @TotalAmountAfterTax, @Remarks, @IsActive;
					END
					-- Close and deallocate the cursor
					CLOSE OrderDetailsCursor;
					DEALLOCATE OrderDetailsCursor;

						--EXEC	 [reservation].[usp_GuestFolioDetails_IU]	
						--			--@LedgerId = 0,
						--	@FolioNumber = @FolioNumber,
						--	@ServiceId = 3,
						--	@Transrefno =@OrderId,
						--	@AmtBeforeTax = @Ledger_TotalAmountBeforeTax,
						--	@taxId = @TaxId,
						--	@taxper = @TaxPer,
						--	@AmtAfterTax = @TotalAmountBeforeTax,
						--	@PaidStatus = 1,
						--	@TransStatus = 1,
						--	@Remarks = @Remarks,
						--	@IsActive = 1,
						--	@LocationID = @LocationID ,
						--	@userId = @userId


						SET @IsSuccess = 1; --success
						SET @Message = 'New Order has been created successfully '--for <b>' + @Message + '</b>';

						END
					ELSE
						BEGIN
						SET @IsSuccess = 0; --success
						SET @Message = 'Order has been Modified Successfully'--for <b>' + @Message + '</b>';
							UPDATE [Housekeeping].[HKLaundryOrder]
								SET [CashPaid] = @CashPaid
								WHERE [OrderId] =@OrderId
						
						--DELETE FROM [Housekeeping].[HKLaundryOrderDetails]
						--INSERT INTO [Housekeeping].[HKLaundryOrderDetails]
						--			([OrderId],[ItemId],[Quantity],[Rate]
						--			,[RateClean],[RatePress],[RateRepair],[TaxId],[TaxPer]
						--			,[ExpresCharge],[ServiceCharge],[ReturnStatus],[Remarks]
						--			,[IsActive],[Clean],[Press],[Repair],[CreatedBy],[Createdon])
									
						--select @OrderId,ItemId,Quantity ,Rate ,
						--		[RateClean],[RatePress],[RateRepair],TaxId ,	TaxPer ,	
						--		ExpresCharge ,	0 ,	0,@Remarks,
						--		1,Clean ,	Press ,	Repair, @userId, GETDATE()						
						--from @LaundryOrderDetails
						
						
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

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message],@OrderId as OrderId
END

