

CREATE Proc [guest].[spAddUpdateTableStructure] 
(
	@StructureData AS [app].[dtTableStructures] READONLY,
	@UserID INT
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
	DECLARE @StructureID int;
	DECLARE @LocationID int;
	

	BEGIN TRY	
	
		BEGIN TRANSACTION		
		
			SELECT @StructureID = (select top 1 [StructureID] from @StructureData) 
			SELECT @LocationID = (select top 1 [LocationID] from @StructureData) 

			if(@StructureID = 0)--New entry
			BEGIN

				INSERT INTO  [Restaurant].[Structure] ([LocationId], [NoOfTables], [BookingCapacity],[ALTERdBy],[ALTERdDate])
				SELECT top 1  [LocationId], [NoOfTables], [BookingCapacity], @UserID, GETDATE() FROM @StructureData

				SELECT @StructureID = StructureID from  [Restaurant].[Structure] where LocationId in( select top 1 [LocationId] from @StructureData)

				INSERT INTO  [Restaurant].[StructureDetails] ([StructureID], [TableNo], [Description], [MaxCapacity], [StatusID])
				SELECT  @StructureID, [TableNo], [Description], [MaxCapacity], 1 FROM @StructureData

				SET @Message = 'Table structure added successfully.';
				SET @IsSuccess = 1; --success

			END
			ELSE
			BEGIN

				DELETE FROM  [Restaurant].[StructureDetails] WHERE [StructureID] =  @StructureID

				INSERT INTO  [Restaurant].[StructureDetails] ([StructureID], [TableNo], [Description], [MaxCapacity], [StatusID])
				SELECT  @StructureID, [TableNo], [Description], [MaxCapacity], [StatusID] FROM @StructureData

				SET @Message = 'Table structure updated successfully.';
				SET @IsSuccess = 1; --success

			END		
			
			
			SET @NotDesc = @Message + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
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
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   

			SET @IsSuccess = 1; --success  
			--SET @Message =  'User Role Objects has been changed successfully.';	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) =@Message -- (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 12,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

