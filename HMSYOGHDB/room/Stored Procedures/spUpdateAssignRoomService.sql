
CREATE Proc [room].[spUpdateAssignRoomService]
(
	@RSHistoryID INT,
	@RoomStatusID INT,
	@LocationID INT,
	@UserID INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
	
	BEGIN TRY
		BEGIN TRANSACTION
			IF(SELECT ReservationID FROM [room].[RoomStatusHistory] WHERE RSHistoryID = @RSHistoryID) IS NULL
				BEGIN
					SET @RoomStatusID = 1;

					UPDATE [room].[RoomStatusHistory]
					SET RoomStatusID = @RoomStatusID
					WHERE RSHistoryID = @RSHistoryID
				END		
					
			UPDATE [todo].[ToDo]
			SET IsCompleted = 1
			,CompletedOn = GETDATE()
			,UpdatedBy = @UserID
			WHERE RSHistoryID = @RSHistoryID

			SET @IsSuccess = 1;
			SET @Message = 'Completed successfully.';	
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
			SET @Message = 'Completed successfully.';	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

