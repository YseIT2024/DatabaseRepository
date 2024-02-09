


create PROC [reservation].[usp_GuestFolioDetails_IU_New]
    @LedgerId int=0,
    @FolioNumber int,	
    @ServiceId int,
	@Transrefno int, 
    @AmtBeforeTax decimal(18, 2),   
	@taxId int,
	@taxper decimal(8, 2),
	@AmtAfterTax decimal(18, 2),
	@PaidStatus int=0,
	@TransStatus int=0,
	@Remarks varchar(250),
	@IsActive bit,	
	@LocationID int,
	@userId int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	    DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		--DECLARE @ContactID int;
		--DECLARE @GenderID int;
		--Declare @ImageID int;
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		--DECLARE @Title varchar(200);
		--DECLARE @Actvity varchar(max);  
    DECLARE @IsComplimentary bit;
	DECLARE @ComplementaryPercentage decimal (18,2);
	DECLARE @ReservationTypeID int;

	SET @ReservationTypeID =(SELECT ReservationTypeID From Reservation.Reservation where FolioNumber=@FolioNumber)
	if(@ReservationTypeID=10)
		BEGIN
		SET @IsComplimentary=1;
		SET @ComplementaryPercentage=100;
		END
	ELSE 
		BEGIN
		SET @IsComplimentary=0 ;
		SET @ComplementaryPercentage=0
		END

		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [account].[GuestLedgerDetails] WHERE LedgerId = @LedgerId)
				Begin
				--UPDATE [account].[GuestLedgerDetails]
				--SET FolioNo = @FolioNumber, TransDate = @TransDate,ServiceId=@ServiceId
				--,TransRefNo=@Transrefno,AmtBeforeTax=@AmtBeforeTax,AmtAfterTax=@AmtAfterTax
				--,TaxId=@taxId,TaxPer=@taxper,PaidStatus=@PaidStatus,TransStatus=@TransStatus,Remarks=@Remarks,
				--IsActive = @IsActive, ModifiedBy = @userId ,ModifiedOn= GETDATE()
				--WHERE  LedgerId = @LedgerId
				SET @IsSuccess = 1; --success 
				--SET @Message = 'Updated successfully.';
				end
			ELSE
				Begin
				Insert Into [account].[GuestLedgerDetails] (FolioNo,TransDate, ServiceId, TransRefNo, AmtBeforeTax,AmtAfterTax,
				TaxId,TaxPer,PaidStatus,TransStatus,Remarks,IsActive,CreatedBy,CreatedOn,AmtTax,IsComplimentary,ComplimentaryPercentage) Values 
				(@FolioNumber,GETDATE(),@ServiceId,@Transrefno,@AmtBeforeTax,@AmtAfterTax,@taxId,
				@taxper,@PaidStatus,@TransStatus,@Remarks,@IsActive,@userId,GETDATE(),
				@AmtAfterTax-@AmtBeforeTax,@IsComplimentary,@ComplementaryPercentage) ---Added by Arabinda on 26/07/2023 to maintain the Tax amount
				--Commented by Arabinda on 18-07-2023------
				--SET @LedgerId = SCOPE_IDENTITY();
				--SET @IsSuccess = 1; --success
				--SET @Message = 'Laundry Order saved successfully.'
				-----------------End----------------
				end
				--SELECT * from [account].[GuestLedgerDetails] where FolioNo=13538
			--EXEC [app].[spInsertActivityLog] 7,@LocationID,@userId
	COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END; 		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@userId	
	END CATCH;  
	--SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	
