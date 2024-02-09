CREATE PROC [service].[uspConciergService_IU]
    @BookingID INT NULL,
    @BookingCode varchar(12) = NULL,
    @ReservationID int,
    @ServiceItemID int,
    @ServiceDate date,
    @ServiceFromTime time = NULL,
    @ServiceToTime time = NULL,
    @AdultCount int,
    @ChildCount int,
    @ServiceRate decimal(18, 2),
    @CarSegmentID int,
	@CarSegmentCost decimal(18, 2),
    @DriverID int,
    @DriverName varchar(100) = NULL,
    @DriverRate decimal(18, 2),
	@GuideID int,        
    @GuideRate decimal(18, 2),
    @Discount decimal(18, 2),
    @TotalAmountBeforeTax decimal(18, 2),
    @TaxPercent decimal(18, 2),
    @TotalTaxAmount decimal(18, 2) = Null,
    @TotalAmountAfterTax decimal(18, 2),
    @AdditionalDiscount decimal(18, 2) = NULL,
    @AdditionalDiscountAmount decimal(18, 2) = NULL,
    @RoundoffAmt decimal(18, 2) = 0,
    @TotalPayableAmount decimal(18, 2),
    @TotalPaidAmount decimal(18, 2) = NULL,
    @RefundAmount decimal(18, 2) = NULL,
    @Hold_TransactionModeID int = NULL,
    @LocationID int,
    @UserID int,   
    @MainCurrencyID int = NULL,
    @CurrencyID int = NULL,
	@Mode varchar(50)=NULL,
	@CurrencyRate decimal(18, 2) = NULL

AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )	
	DECLARE @Actvity varchar(max);
	DECLARE @folioNumber int ;
	--DECLARE @TaxId int ;
    SET @folioNumber=(SELECT FolioNumber FROM reservation.Reservation WHERE ReservationID = @ReservationID)
	DECLARE @TaxId int = (SELECT  TaxID  FROM service.ServiceTax WHERE ServiceTypeID=16 and IsActive=1)
	DECLARE @TaxPer decimal(8, 2) = (SELECT TaxRate FROM general.Tax WHERE TaxID=@TaxId and IsActive=1)

	DECLARE @AmtAfterTax decimal(18, 2)=@TotalPayableAmount;
	DECLARE @LineTotalTax decimal(18, 3)=@TotalPayableAmount/(1+@TaxPer);
	DECLARE @LineTotalBT decimal(18, 3)=@TotalPayableAmount-@LineTotalTax;

	BEGIN TRY

	IF(@BookingID > 0)
	BEGIN
		BEGIN TRANSACTION
			UPDATE service.ConciergService
			SET    BookingCode = @BookingCode, ReservationID = @ReservationID, ServiceItemID = @ServiceItemID, 
				   ServiceDate = @ServiceDate, ServiceFromTime = @ServiceFromTime, ServiceToTime = @ServiceToTime, 
				   AdultCount = @AdultCount, ChildCount = @ChildCount, ServiceRate = @ServiceRate, CarSegmentID = @CarSegmentID, CarSegmentCost = @CarSegmentCost,
				   DriverID = @DriverID, DriverRate = @DriverRate, GuideID = @GuideID, GuideRate = @GuideRate, 
				   Discount = @Discount, TotalAmountBeforeTax = @LineTotalBT, TaxPercent = @TaxPer, 
				   TotalTaxAmount = @LineTotalTax, TotalAmountAfterTax = @TotalAmountAfterTax, AdditionalDiscount = @AdditionalDiscount, 
				   AdditionalDiscountAmount = @AdditionalDiscountAmount, RoundoffAmt = @RoundoffAmt, TotalPayableAmount = @TotalPayableAmount, 
				   TotalPaidAmount = @TotalPaidAmount, RefundAmount = @RefundAmount, Hold_TransactionModeID = @Hold_TransactionModeID, 
				   LocationID = @LocationID, MainCurrencyID = @MainCurrencyID, 
				   CurrencyID = @CurrencyID,
				   Mode=@Mode,
				   CurrencyRate=@CurrencyRate
			WHERE  BookingID = @BookingID   

			SET @IsSuccess = 1; --success 
			SET @Message = 'Service Booking has been updated successfully.';	
			SET @Title = 'Service Name: ' + STR(@ServiceItemID) + ' updated';						
			SET @Actvity  = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
			EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID

			SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserId as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc		
		
		
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN	
		BEGIN TRANSACTION

			INSERT INTO service.ConciergService ( BookingCode, ReservationID, ServiceItemID, ServiceDate, 
													ServiceFromTime, ServiceToTime, AdultCount, ChildCount, ServiceRate, 
													CarSegmentID, CarSegmentCost, DriverID, DriverRate, GuideID, GuideRate, 
													Discount, TotalAmountBeforeTax, TaxPercent, TotalTaxAmount, 
													TotalAmountAfterTax, AdditionalDiscount, AdditionalDiscountAmount, 
													RoundoffAmt, TotalPayableAmount, TotalPaidAmount, RefundAmount, 
													Hold_TransactionModeID, LocationID, UserID, DateTime, MainCurrencyID, 
													CurrencyID,Mode,CurrencyRate)
								
			SELECT  @BookingCode, @ReservationID, @ServiceItemID, @ServiceDate, @ServiceFromTime, 
					@ServiceToTime, @AdultCount, @ChildCount, @ServiceRate, @CarSegmentID, @CarSegmentCost, @DriverID,  
					@DriverRate, @GuideID, @GuideRate, @Discount,  @LineTotalBT, @TaxPer, @LineTotalTax, 
					@TotalAmountAfterTax, @AdditionalDiscount, @AdditionalDiscountAmount, @RoundoffAmt, @TotalPayableAmount, 
					@TotalPaidAmount, @RefundAmount, @Hold_TransactionModeID, @LocationID, @UserID, GETDATE(), 
					@MainCurrencyID, @CurrencyID,@Mode,@CurrencyRate

					SET @BookingID = SCOPE_IDENTITY();

					EXEC [reservation].[usp_GuestFolioDetails_IU]
						   
										@FolioNumber= @folioNumber,	
										@ServiceId =16,     
										@Transrefno=@BookingID, 
										@AmtBeforeTax =@TotalAmountBeforeTax, 
										@taxId =@TaxId,
										@taxper =@TaxPercent,
										@AmtAfterTax =@TotalAmountAfterTax,
										@PaidStatus= 1,
										@TransStatus =1,
										@Remarks ='NEW TRIP',
										@IsActive =1,	
										@LocationID =@LocationID,
										@userId =@userId
					

					SET @IsSuccess = 1; --success 
					SET @Message = 'Service Type has been created successfully.';	
					SET @Title = 'Service Name: ' +STR( @ServiceItemID) + ' created';						
					SET @Actvity  = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID

					
					SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc

			
		COMMIT TRANSACTION
	END
	
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
		END;  
		
		---------------------------- Insert into activity log---------------	
		--DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		--EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID	
	  END CATCH; 
			SELECT @IsSuccess AS IsSuccess, @Message as [Message], @UserID as [EmployeeID]

		------------------------------------


	
	
	

	
