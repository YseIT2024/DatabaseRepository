
CREATE PROCEDURE [reservation].[spReInstateReservation]
(	
	@ReservationID int,
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
	Declare @DateDifference int, @Nights int, @FolioNumber int
	Declare @CancellationPercent decimal(18,4);
	Declare @ExpectedCheckIn Datetime;

	IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID) in (15)) --No Show
	BEGIN
		BEGIN TRY  
			BEGIN TRANSACTION	

				UPDATE [reservation].[Reservation]
				SET ReservationStatusID = 1 -- Reserved 			
				WHERE ReservationID = @ReservationID
			
				UPDATE [reservation].[CancellationDetail] 
				set [ReservationStatusID] = 16 -- ReInstate
				WHERE ReservationID = @ReservationID				
			
				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[UserID],[DateTime])
				VALUES(@ReservationID, 1 -- Reserved 	
				, @UserID, GETDATE())

				SET @IsSuccess = 1; --Success
				SET @Message = 'No show has been updated to Re-Instate successfully.';

				SELECT @FolioNumber = FolioNumber FROM reservation.Reservation WHERE ReservationID = @ReservationID

				DECLARE @Title varchar(200) = 'Re-Instate Reservation for ReservationID- '+ Cast(@ReservationID AS Varchar(20))+' and ' + (SELECT CONCAT(@Location, FolioNumber) FROM reservation.Reservation WHERE ReservationID = @ReservationID) 
				+cast(@FolioNumber As varchar(20))+ ' folio number completed successfully.'
				DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' By UserID- '+ Cast(@UserID AS Varchar(20))+' .' ;
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			COMMIT TRANSACTION
			EXEC [app].[spInsertActivityLog]38,@LocationID,@NotDesc,@UserID, @Message	
		END TRY  
		BEGIN CATCH    
			IF (XACT_STATE() = -1) 
			BEGIN  			
				ROLLBACK TRANSACTION;  

				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --Error			
			END; 
		
			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog]38,@LocationID,@Act,@UserID, @Message	
		END CATCH;  
	END
	ELSE
		BEGIN
			SET @Message = 'An error occurred in database please refresh the page';
			SET @IsSuccess = 0; --Error		
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message],@FolioNumber as FolioNumber
END









