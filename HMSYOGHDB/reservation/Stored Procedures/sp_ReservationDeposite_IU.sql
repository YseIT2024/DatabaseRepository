create PROC [reservation].[sp_ReservationDeposite_IU]
	@StandardReservationDepositId INT=Null,
    @ReservationModeId INT=Null,
    @ReservationTypeId INT=Null,
    @SubcategoryId INT=Null,
    @StandardReservationDepositPercent DECIMAL(5,2),
    @EffectiveFrom DATETIME,
    @EffectiveTo DATETIME,
    @IsActive INT,
    @ReservationDayFrom INT,
    @ReservationDayTo INT=Null,
	@LocationId int=null,
	@UserId int=null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Act VARCHAR(MAX)='';
	DECLARE @Title varchar(max) = 'Reservation Deposite';

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';	
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [reservation].[StandardReservationDeposit] WHERE StandardReservationDepositId = @StandardReservationDepositId)
				Begin	
					UPDATE [reservation].[StandardReservationDeposit]
					SET
					ReservationModeId = @ReservationModeId,
					ReservationTypeId = @ReservationTypeId,
					SubcategoryId = @SubcategoryId,
					StandardReservationDepositPercent = @StandardReservationDepositPercent,
					EffectiveFrom = @EffectiveFrom,
					EffectiveTo = @EffectiveTo,
					IsActive = @IsActive,
					ReservationDayFrom = @ReservationDayFrom,
					ReservationDayTo = @ReservationDayTo
					WHERE
                    StandardReservationDepositId = @StandardReservationDepositId
				
				SET @IsSuccess = 1; --success 
				SET @Message = 'Reservation Deposite Updated Successfully';
				End
			
			ELSE
			BEGIN
				 -- Perform INSERT operation
					INSERT INTO [reservation].[StandardReservationDeposit]
					(
						ReservationModeId,
						ReservationTypeId,
						SubcategoryId,
						StandardReservationDepositPercent,
						EffectiveFrom,
						EffectiveTo,
						IsActive,
						ReservationDayFrom,
						ReservationDayTo
					)
					VALUES
					(
						@ReservationModeId,
						@ReservationTypeId,
						@SubcategoryId,
						@StandardReservationDepositPercent,
						@EffectiveFrom,
						@EffectiveTo,
						@IsActive,
						@ReservationDayFrom,
						@ReservationDayTo
					)
				SET @StandardReservationDepositId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Reservation Deposite Inserted successfully'
			
			
			END
			
			SET @NotDesc = @Message +'for Reservation Deposite Id:'+ STR(@StandardReservationDepositId)  + ' And Reservation Deposite Percentage'+ CAST(@StandardReservationDepositPercent as Varchar(10))+'  on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserId as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LocationId, @Title, @NotDesc
			Set @Act= @NotDesc; 
		    EXEC [app].[spInsertActivityLog]29,@LocationID,@Act,@UserId	
			
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
		 Set @Act= @Message;
		 EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserId	
			
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	

