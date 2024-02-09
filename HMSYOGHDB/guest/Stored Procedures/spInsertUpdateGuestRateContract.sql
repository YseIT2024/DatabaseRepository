CREATE PROCEDURE [guest].[spInsertUpdateGuestRateContract] 
(	
	@RateContractID int,
	@GuestCompanyID int,
    @ItemID int,   
    @ContractFrom datetime,
    @ContractTo datetime,
    @NetRate decimal(18,6),
   -- @SellRate decimal(18,6),
    @DiscountPercent int,
   -- @DiscountAmt decimal(18,6),
    @IsActive bit,
    @CreatedBy varchar(50),
	@LocationID	 int
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
	
			BEGIN TRANSACTION				
					 
						IF(@RateContractID = 0)
						--GENERATE COMPANY ID 

						BEGIN								
									if Exists(select ItemID from [guest].[GuestCompanyRateContract]   WHERE ((ContractFrom <= @ContractTo) AND (ContractTo >= @ContractFrom)) 
										and ItemID = @ItemID and GuestCompanyID = @GuestCompanyID and IsActive = 1)
									BEGIN 
												SET @Message = 'Rate contract date is overlaping. Please check the dates';
									END
									ELSE
									BEGIN
										INSERT INTO [guest].[GuestCompanyRateContract]
										   ([GuestCompanyID],[ItemID]
										   ,[ContractFrom],[ContractTo],[NetRate],[SellRate]
										   ,[DiscountPercent],[DiscountAmt],[IsActive],[CreatedBy]
										   ,[CreatedOn])     
									   VALUES
										  (@GuestCompanyID,@ItemID,
										   @ContractFrom,@ContractTo,@NetRate, @NetRate - ((@NetRate * @DiscountPercent)/100), 
										   @DiscountPercent,(@NetRate * @DiscountPercent)/100,@IsActive,@CreatedBy, 
										   GETDATE())
					
										--[Change details-Author: Arabinda, Modified on:25/01/2025, Description: As advised by ------ for --------
										--SET @AccountGroupID = SCOPE_IDENTITY();

										SET @Message = 'Rate contract has been added successfully.';	
										SET @IsSuccess = 1;
									END
						END
						ELSE
						BEGIN
									if Exists(select ItemID from [guest].[GuestCompanyRateContract]   WHERE ((ContractFrom <= @ContractTo) AND (ContractTo >= @ContractFrom)) 
										and ItemID = @ItemID and GuestCompanyID = @GuestCompanyID and IsActive = 1 and [RateContractID] <> @RateContractID)
									BEGIN 
												SET @Message = 'Rate contract date is overlaping. Please check the dates';
									END
									ELSE
									BEGIN

										UPDATE [guest].[GuestCompanyRateContract]
										   SET ItemID = @ItemID						  
											  ,ContractFrom = @ContractFrom
											  ,ContractTo = @ContractTo
											  ,NetRate = @NetRate
											  ,SellRate = @NetRate - ((@NetRate * @DiscountPercent)/100)
											  ,DiscountPercent = @DiscountPercent
											  ,DiscountAmt = (@NetRate * @DiscountPercent)/100
											  ,IsActive = @IsActive
											 , ModifiedBy=@CreatedBy
											  ,ModifiedOn=GETDATE()
											 -- ,CreatedBy = @CreatedBy
											--  ,CreatedOn = GETDATE()
										 WHERE [RateContractID]=@RateContractID AND [GuestCompanyID]=@GuestCompanyID

										SET @Message = 'Rate contract has been updated successfully.';
										SET @IsSuccess = 1;
									END

						END	
						
						SET @NotDesc = @Message +'for ItemID:'+ STR(@ItemID) + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@CreatedBy as varchar(10));
						EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
								
					
			COMMIT TRANSACTION		
	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;    
    
		--IF (XACT_STATE() = 1)  
		--BEGIN  			
		--	COMMIT TRANSACTION;   
		--	SET @IsSuccess = 1; --success 
		--	IF(@RateContractID = 0)
		--	BEGIN 
		--		SET @Message = 'Rate contract has been added successfully.';
		--	END
		--	ELSE
		--	BEGIN
		--		SET @Message = 'Rate contract has been updated successfully.';
		--	END
		--END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]18,@RateContractID,@Act,@CreatedBy	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @RateContractID as [RateContractID]
END
