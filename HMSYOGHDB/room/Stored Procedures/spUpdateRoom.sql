CREATE PROCEDURE [room].[spUpdateRoom]
(
	@RoomID int,	
	@RoomTypeID int,
	@FloorID int,	
	@UserID int,
	@MaxCapacity int,		
	@Windows int = null,
	@Balconies int = null,
	@Description varchar(250) = null,
	@RoomSize varchar(50) = null,
	@RoomNote varchar(250) = null,
	@FeatureID int,
	@LocationID int
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);
	DECLARE @RoomNo INT = 0;

	BEGIN TRY  
		BEGIN TRANSACTION
			IF((SELECT RoomTypeID FROM room.Room WHERE RoomID = @RoomID) = @RoomTypeID)
				BEGIN
					UPDATE room.Room
					SET RoomTypeID = @RoomTypeID
					,FloorID = @FloorID			
					,MaxCapacity = @MaxCapacity			  
					WHERE RoomID = @RoomID AND IsActive = 1

					UPDATE [room].[Feature]
					SET [Description] = @Description
					,[Windows] = @Windows
					,[Balconies] = @Balconies
					,[RoomSize] = @RoomSize
					,[RoomNote] = @RoomNote
					WHERE FeatureID = @FeatureID

					SET @Message = 'Room details has been updated successfully.';
				END
			ELSE
				BEGIN
					SET @RoomNo  = (SELECT [RoomNo] FROM room.Room WHERE RoomID = @RoomID AND IsActive = 1)

					UPDATE room.Room
					SET IsActive = 0					  
					WHERE RoomID = @RoomID

					INSERT INTO [room].[Feature]
					([Description],[Windows],[Balconies],[RoomSize],[RoomNote])
					VALUES(@Description, @Windows, @Balconies, @RoomSize, @RoomNote)

					SET @FeatureID  = SCOPE_IDENTITY();

					INSERT INTO [room].[Room]
					([RoomNo], [RoomTypeID], [FloorID],[LocationID], [UserID], [MaxCapacity], [FeatureID])				
					VALUES(@RoomNo, @RoomTypeID, @FloorID, @LocationID, @UserID, @MaxCapacity, @FeatureID)

					SET @Message = 'Room type has been saved successfully.'
				END
					
				SET @IsSuccess = 1;					
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
			IF(@RoomNo = 0)
			BEGIN
				SET @Message = 'Room details has been updated successfully.';
			END	
			ELSE
			BEGIN
				SET @Message = 'Room type has been saved successfully.'
			END
		END;  
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


