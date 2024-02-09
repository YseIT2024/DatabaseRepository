
-- =============================================
-- Author:          <ARABINDA PADHI>
-- Create date: <25/01/2023>
-- Description:     <TO INSERT AND UPDATE THE GUEST COMPANY>
-- =============================================

CREATE PROCEDURE [guest].[spInsertUpdateGuestCompany] 
(
  @CompanyID int,
  @CompanyName varchar(100),
  @CompanyAddress nchar(250),
  @CompanyStreet varchar(100),
  @CompanyCity varchar(100),
  @CompanyState varchar(100),
  @CompanyCountryId int,
  @CompanyZIP varchar(20),
  @CompanyPhoneNumber varchar(15),
  @CompanyEmail varchar(50),
  @POCName varchar(50),
  @POCDisignation varchar(100),
  @POCPhone varchar(15),
  @POCEmail varchar(50),
  @CreatedBy int,
  @LocationID int,
  @ReservationTypeId int,
  @IsActive bit,
  @IsCredit bit,
  @PaymentReceiveTypeID int,
  @CreditPeriod int,
  @IntrestPercentage int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
	
	BEGIN TRY				
				 IF (@CompanyID>0)
					BEGIN					
					IF EXISTS(SELECT CompanyName FROM guest.GuestCompany WHERE CompanyName = ltrim(@CompanyName) and CompanyID <> @CompanyID)
						BEGIN
							SET @Message =  'Company/Corporate name already exists. Please enter unique name.'
					END
					ELSE
					BEGIN
						UPDATE guest.GuestCompany SET
						  CompanyName = @CompanyName,
						  CompanyAddress = @CompanyAddress,
						  CompanyStreet = @CompanyStreet,
						  CompanyCity = @CompanyCity,
						  CompanyState = @CompanyState,
						  CompanyCountryId = @CompanyCountryId,
						  CompanyZIP = @CompanyZIP,
						  CompanyPhoneNumber = @CompanyPhoneNumber,
						  CompanyEmail = @CompanyEmail,
						  POCName = @POCName,
						  POCDisignation = @POCDisignation,
						  POCPhone = @POCPhone,
						  POCEmail = @POCEmail,
						  CreatedBy = @CreatedBy,
						  CreatedOn = GetDate(),					 
						  ReservationTypeId = @ReservationTypeId,
						  IsActive = @IsActive,
						  IsCredit = @IsCredit,
						  PaymentReceiveTypeID = @PaymentReceiveTypeID,
						  CreditPeriod = @CreditPeriod,
						  IntrestPercentageAfterCreditPeriod=@IntrestPercentage
						WHERE CompanyID = @CompanyID

						SET @IsSuccess = 1; --success 
						SET @Message = 'Company/Corporate has been updated successfully.';	
						SET @Title = 'Company/Corporate: ' + @CompanyName + ' updated';
					END
					END
				  ELSE	
					BEGIN
					IF EXISTS(SELECT CompanyName FROM guest.GuestCompany WHERE CompanyName = ltrim(@CompanyName))
						BEGIN
							SET @Message =  'Company/Corporate name already exists. Please enter unique name.'
					END
					ELSE
					BEGIN

						INSERT INTO guest.GuestCompany 
						(CompanyName,CompanyAddress, CompanyStreet, CompanyCity, CompanyState,CompanyCountryId, CompanyZIP,
						  CompanyPhoneNumber,CompanyEmail,POCName,POCDisignation,POCPhone, POCEmail,CreatedBy, CreatedOn,ReservationTypeId, IsActive,
						  IsCredit,PaymentReceiveTypeID,CreditPeriod,IntrestPercentageAfterCreditPeriod)
						VALUES
						(@CompanyName, @CompanyAddress,@CompanyStreet,@CompanyCity, @CompanyState,@CompanyCountryId, @CompanyZIP,
						  @CompanyPhoneNumber, @CompanyEmail, @POCName,	@POCDisignation,@POCPhone,@POCEmail,@CreatedBy,	GetDate(), @ReservationTypeId,@IsActive,
						  @IsCredit,@PaymentReceiveTypeID,@CreditPeriod,@IntrestPercentage)			
						SET @IsSuccess = 1; --success 
						SET @Message = 'Company/Corporate has been created successfully.';
						SET @Title = 'Company/Corporate: ' + @CompanyName + ' created';
					END
				END
				
				SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@CreatedBy as varchar(10));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
	
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
			IF(@CompanyID = 0)
			BEGIN 
				SET @Message = 'Company/Corporate has been added successfully.';
			END
			ELSE
			BEGIN
				SET @Message = 'Company/Corporate has been updated successfully.';
			END
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]28,@CompanyID,@Act,@CreatedBy	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @CompanyID as [CompanyID]
END


