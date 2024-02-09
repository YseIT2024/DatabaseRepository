
CREATE PROCEDURE [room].[spCreateRoom]
(
	@RoomNo int,
	@RoomTypeID int,
	@FloorID int,	
	@LocationID int,
	@UserID int,
	@MaxCapacity int,
	@MaxChildCapacity int,
	@Windows int = null,
	@Balconies int = null,
	@Description varchar(250) = null,
	@RoomSize varchar(50) = null,
	@RoomNote varchar(250) = null
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);

	IF EXISTS(SELECT RoomID FROM room.Room WHERE RoomNo = @RoomNo AND LocationID = @LocationID)
		BEGIN
			SET @Message = 'Room number already exists. Please insert unique room number.'
		END
	ELSE
		BEGIN TRY  
			BEGIN TRANSACTION
				INSERT INTO [room].[Feature]
				([Description],[Windows],[Balconies],[RoomSize],[RoomNote])
				VALUES(@Description, @Windows, @Balconies, @RoomSize, @RoomNote)

				DECLARE @FeatureID int = SCOPE_IDENTITY();

				--INSERT INTO [room].[Room]
				--([RoomNo], [RoomTypeID], [FloorID],[LocationID], [UserID], [MaxCapacity], [FeatureID])				
				--VALUES(@RoomNo, @RoomTypeID, @FloorID, @LocationID, @UserID, @MaxCapacity, @FeatureID) 		
				INSERT INTO HMSMASTER.Products.room	
				([RoomNo], SubCategoryID, [FloorID],[LocationID], CreatedBy, MaxAdultCapacity,MaxChildCapacity, FeatureID)				
				VALUES(@RoomNo, @RoomTypeID, @FloorID, @LocationID, @UserID, @MaxCapacity,@MaxChildCapacity, @FeatureID)

				SET @IsSuccess = 1;
				SET @Message = 'New room has been saved successfully.'
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
				SET @Message = 'New room has been saved successfully.'
			END;  

			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
		END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


