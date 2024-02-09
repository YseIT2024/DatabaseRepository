

CREATE Proc [general].[Warehousetrns]
(
	@WarehouseID int,
	@Code varchar(5) ,
	@Description varchar(100),
	@Address varchar(255),
	@Remarks varchar(255),
	@IsActive bit,
	@UserID int,
	@LocationID int,
	@MappedLocationIDs AS [general].[dtWarehouseLocationMap] READONLY
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
			
			IF (@WarehouseID = 0) --Create
				BEGIN

				IF(EXISTS(SELECT [Code] FROM [general].[Warehouse] WHERE [Code] = @Code ))
				BEGIN

					SET @Message = 'Warehouse Code already exists.';
					SET @IsSuccess = 0;

				END
				ELSE
				BEGIN
					INSERT INTO [general].[Warehouse]
					([Code],[Description],[Address],[Remarks],[IsActive],[CreatedBy],[CreatedDate])
					VALUES(@Code,@Description,@Address,@Remarks,@IsActive,@UserID,GETDATE())
		
					SELECT @WarehouseID = [WarehouseID] from [general].[Warehouse] where [Code] = @Code

					INSERT INTO [general].[WarehouseLocationMap] ([LocationID], [WarehouseID], [CreatedBy], [CreatedDate])
					SELECT  [LocationID], @WarehouseID, @UserID, GETDATE() FROM @MappedLocationIDs

					SET @Message = 'New Warehouse added.';
					SET @IsSuccess = 1; --success

					SET @Title = 'Warehouse: ' + 'New Warehouse:'+ @Code + ' added';
					SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					
	     			EXEC [app].[spInsertActivityLog]8,@LocationID,@Title,@UserID

				END

			END
			ELSE --Update
				BEGIN

					IF(EXISTS(SELECT [Code] FROM [general].[Warehouse] WHERE [Code] = @Code and [WarehouseID] <> @WarehouseID))
					BEGIN

						SET @Message = 'Warehouse Code already exists.';
						SET @IsSuccess = 0;

					END
				ELSE
				BEGIN

					UPDATE [general].[Warehouse]
					SET [Code] = @Code, [Description] = @Description, [Address] = @Address, [Remarks] = @Remarks, [IsActive] = @IsActive
					WHERE [WarehouseID] = @WarehouseID

					DELETE [general].[WarehouseLocationMap] WHERE [WarehouseID] = @WarehouseID

					INSERT INTO [general].[WarehouseLocationMap] ([LocationID], [WarehouseID], [CreatedBy], [CreatedDate])
					SELECT  [LocationID], [WarehouseID], @UserID, GETDATE() FROM @MappedLocationIDs

					SET @Message = 'Warehouse updated successfully.';
					SET @IsSuccess = 1; --success

					SET @Title = 'Warehouse: ' + @Code + ' updated';
					SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					
	     			EXEC [app].[spInsertActivityLog]8,@LocationID,@Title,@UserID

				END
			END			
					
			--END
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
		EXEC [app].[spInsertActivityLog]8,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

