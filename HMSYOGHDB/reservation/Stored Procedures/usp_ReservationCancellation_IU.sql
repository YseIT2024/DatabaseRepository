CREATE Proc [reservation].[usp_ReservationCancellation_IU]
    @CancellationId int,
    --@FolioNumber int = null,
    @ReservationID int,
    @CancellationReason nvarchar(100),
    @ActionID int,
    @StatusID int,
    @UserID int,
    --@DateTime datetime,
    @IsActive bit,
	@LocationID int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @LocationCode VARCHAR(10);
	
	BEGIN TRY
		BEGIN TRANSACTION
		IF EXISTS (SELECT ReservationID  FROM reservation.ReservationCancellation WHERE ReservationID = @ReservationID)		
			BEGIN
				UPDATE reservation.ReservationCancellation
				SET    --CancellationId = @CancellationId, FolioNumber = @FolioNumber, 
				CancellationReason = @CancellationReason, 
					   ActionID = @ActionID, [StatusID] = @StatusID, UserID = @UserID, [DateTime] = GETDate(), IsActive = @IsActive
				WHERE  ReservationID = @ReservationID
				SET @IsSuccess = 1; --success 
				SET @Message = 'Cancellation modified successfully.';
			END
		ELSE
			BEGIN
				INSERT INTO reservation.ReservationCancellation ( ReservationID, CancellationReason, 
															 ActionID, StatusID, UserID, DateTime, IsActive)  
	
				SELECT   @ReservationID, @CancellationReason, @ActionID, @StatusID, @UserID, 
				   GETDate(), @IsActive

				   UPDATE [reservation].[Reservation]
					SET ReservationStatusID = 2 --Canceled
					WHERE  ReservationID = @ReservationID

					IF(@CancellationReason IS NOT NULL)
							BEGIN
								INSERT INTO [reservation].[Note]
								([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
								VALUES(4,@ReservationID,@CancellationReason,@UserID,GETDATE()) --4 = Remarks
							END

				SET @IsSuccess = 1; --success 
				SET @Message = 'Reservation request canceled successfully.';
			END
   
	   /*
		-- Begin Return row code block

		SELECT CancellationId, FolioNumber, ReservationID, CancellationReason, ActionID, Status, UserID, 
			   DateTime, IsActive
		FROM   reservation.ReservationCancellation
		WHERE  CancellationId = @CancellationId AND FolioNumber = @FolioNumber AND ReservationID = @ReservationID AND 
			   CancellationReason = @CancellationReason AND ActionID = @ActionID AND Status = @Status AND 
			   UserID = @UserID AND DateTime = @DateTime AND IsActive = @IsActive

		-- End Return row code block

		*/
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
			SET @Message = 'Updated successfully.';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH; 	

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message] 
END
