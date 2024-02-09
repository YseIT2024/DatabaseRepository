CREATE PROC [service].[uspTypeIU]
    @ServiceTypeID INT=NULL,
    @ServiceName varchar(100),
    @Description varchar(150),
    @ShowInUI bit,
    @InvoiceTitle varchar(100),
	@IsActive BIT,
	@UserId INT	,	
	@LocationID INT,
	@IsTaxable BIT--Added By Rajendra

	
AS 
BEGIN
    SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )	
	DECLARE @Actvity varchar(max);
	
	BEGIN TRY				
				 IF(@ServiceTypeID>0)
					BEGIN 
					BEGIN TRANSACTION
						UPDATE service.Type
						SET ServiceName = @ServiceName, [Description] = @Description, ShowInUI = @ShowInUI, InvoiceTitle = @InvoiceTitle,IsActive = @IsActive,Istaxable=@IsTaxable,
						ModifiedBy=@UserId, ModifiedOn=FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm')
						WHERE  ServiceTypeID = @ServiceTypeID

						--Begin Return row code block
						 --   SELECT ServiceTypeID, ServiceName, Description, ShowInUI, InvoiceTitle,
							--IsActive,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn
						 --   FROM   service.Type
						 --End Return row code block

						SET @IsSuccess = 1; --success 
						SET @Message = 'Service Type has been updated successfully.';	
						SET @Title = 'Service Name: ' + @ServiceName + ' updated';						
						SET @Actvity  = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
						EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID

						SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserId as varchar(10));
						EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
					COMMIT TRANSACTION	
					END
				  ELSE	
					BEGIN
						BEGIN TRANSACTION
						IF EXISTS (SELECT ServiceName FROM service.Type WHERE ServiceName = @ServiceName)
								BEGIN
									SET @Message = 'Service Name already exists.';
								END
								ELSE
								BEGIN
								INSERT INTO service.Type (ServiceName, Description, ShowInUI, InvoiceTitle,
								IsActive,IsTaxable,CreatedBy,CreatedOn)
								SELECT  @ServiceName, @Description, @ShowInUI, @InvoiceTitle,
								@IsActive,@IsTaxable,@UserId,FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm')
							

								--Begin Return row code block
								--   SELECT ServiceTypeID, ServiceName, Description, ShowInUI, InvoiceTitle,
								--IsActive,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn
								--   FROM   service.Type
								--End Return row code block

								SET @IsSuccess = 1; --success 
								SET @Message = 'Service Type has been created successfully.';	
								SET @Title = 'Service Name: ' + @ServiceName + ' created';						
								SET @Actvity  = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
								EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@UserID

								SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
								EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
								END
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

END
