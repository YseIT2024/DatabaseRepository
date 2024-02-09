CREATE Proc [room].[spCloseHouseKeeping]
(
	@RoomID int,
	@LocationID int,	
	@UserID int
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
	DECLARE @RSHistoryID int;

	BEGIN TRY  
		BEGIN TRANSACTION
			SET @RSHistoryID = (SELECT MAX(rsh.RSHistoryID) FROM [room].[RoomStatusHistory] rsh 
			INNER JOIN [todo].[ToDo] td ON rsh.RSHistoryID = td.RSHistoryID AND rsh.RoomID = @RoomID AND td.IsCompleted = 0)

			UPDATE [todo].[ToDo] SET IsCompleted = 1 WHERE RSHistoryID = @RSHistoryID

			SET @Message = 'House Keeping has been closed successfully.';
															
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
			SET @Message = 'House Keeping has been closed successfully.';
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



