

CREATE Proc [Products].[FeatureTrans]
(
	@FeatureID int,
	@CategoryID int,
	@Name varchar(100),
	@Group varchar(50),
	@Remarks varchar(200),
	@IsActive bit,
	@UserID int,
	@LocationID int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';	

	BEGIN TRY		
		BEGIN TRANSACTION			
			IF(	@FeatureID = 0) --Create
				BEGIN
					IF(EXISTS(SELECT [Name] FROM  [Products].[Features] WHERE [Name] = @Name))
						BEGIN						 
							SET @Message = 'Feature name already exists.';
							SET @IsSuccess = 0; 
						END
					ELSE
						BEGIN
							INSERT INTO  [Products].[Features] ([CategoryID],[Name],[Group],[Remarks],[IsActive],[CreatedBy],[CreateDate])
							VALUES (@CategoryID, @Name, @Group, @Remarks, @IsActive, @UserID, GETDATE())

							SET @Message = 'Feature added successfully.';
							SET @IsSuccess = 1; --success
					
							SET @Title = 'Feature: ' + @Name + ' added successfully';
							SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
							EXEC [app].[spInsertActivityLog]25,@LocationID,@Title,@UserID
						END
				END
			ELSE
				BEGIN
					IF(EXISTS(SELECT [Name] FROM  [Products].[Features] WHERE [Name] = @Name and [FeatureID] <> @FeatureID))
						BEGIN						 
							SET @Message = 'Feature name already exists.';
							SET @IsSuccess = 0; 
						END
					ELSE
						BEGIN
							UPDATE  [Products].[Features]
							SET [CategoryID] = @CategoryID, [Name] = @Name, [Group] = @Group , [Remarks]= @Remarks, [IsActive]= @IsActive
							WHERE [FeatureID] = @FeatureID						

							SET @Message = 'Feature updated successfully.';
							SET @IsSuccess = 1; --success

							SET @Title = 'Feature: ' + @Name + ' updated';
							SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));		
							EXEC [app].[spInsertActivityLog]25,@LocationID,@Title,@UserID
	     				END
				END
			
				
		COMMIT TRANSACTION	
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
		END;  
		
		--------------Insert into activity log----------------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]25,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

