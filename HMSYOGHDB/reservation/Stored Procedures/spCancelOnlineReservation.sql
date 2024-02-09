Create PROCEDURE [reservation].[spCancelOnlineReservation]
(	
	@OnlineReservationID int,
	@Reason varchar(350),
	@LocationID int,
	@UserID int,
	@CancellationModeID int,
	@CancellationCharge decimal(18, 4),
	@Refund decimal(18, 4),
	@RequestedOn datetime
)
AS
BEGIN
	
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
	Declare @DateDifference int, @Nights int, @FolioNumber int
	Declare @CancellationPercent decimal(18,4);
	Declare @ReservationStatusID int;
	Declare @ExpectedCheckIn Datetime;
	Declare @reservationID int;


	IF(EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE OnlineReservationID = @OnlineReservationID AND LocationID = @LocationID))
	BEGIN
		BEGIN TRY  
			BEGIN TRANSACTION
			SET @reservationID=(SELECT ReservationID FROM reservation.Reservation WHERE OnlineReservationID = @OnlineReservationID AND LocationID = @LocationID)

			IF((Select SUM(ActualAmount) From [account].[Transaction] where ReservationID=@reservationID) > 0)
			BEGIN
			UPDATE [reservation].[Reservation]
				SET ReservationStatusID = 17 --Pending For Cancellation
				WHERE ReservationID = @reservationID

				INSERT INTO [reservation].[CancellationDetail]
				([ReservationID], [ReservationStatusID], [CancellationModeID],[CancellationCharge], [Refund], [CreatedBy],[CreatedDate], [Reason], [RequestedOn])
				VALUES(@reservationID, 17,  @CancellationModeID, @CancellationCharge, @Refund, @UserID, GETDATE(), @Reason, @RequestedOn)

				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[UserID],[DateTime],[Remarks])
				VALUES(@reservationID, 17, @UserID, GETDATE(),@Reason)

				SET @IsSuccess = 1;
				SET @Message = 'Reservation has been Pending For Cancellation.';
			END

			ELSE

			UPDATE [reservation].[Reservation]
				SET ReservationStatusID = 2 --Canceled
				WHERE ReservationID = @reservationID

				INSERT INTO [reservation].[CancellationDetail]
				([ReservationID], [ReservationStatusID], [CancellationModeID],[CancellationCharge], [Refund], [CreatedBy],[CreatedDate], [Reason], [RequestedOn])
				VALUES(@reservationID, 2,  @CancellationModeID, @CancellationCharge, @Refund, @UserID, GETDATE(), @Reason, @RequestedOn)

				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[UserID],[DateTime],[Remarks])
				VALUES(@reservationID, 2, @UserID, GETDATE(),@Reason)

				SET @IsSuccess = 1;
				SET @Message = 'Reservation has been Canceled .';

			COMMIT TRANSACTION
		END TRY  
		BEGIN CATCH    
			IF (XACT_STATE() = -1) 
			BEGIN  			
				ROLLBACK TRANSACTION;  

				SET @Message = ERROR_MESSAGE();
				SET @IsSuccess = 0; --Error			
			END;    
    
			IF (XACT_STATE() = 1)  
			BEGIN  			
				COMMIT TRANSACTION;   

				SET @IsSuccess = 1; --Success  
				--SET @Message = 'Reservation has been canceled successfully.';
			END;  
		
			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
		END CATCH;  
	END
	ELSE
		BEGIN
			SET @Message = 'An error occurred in database please refresh the page';
			SET @IsSuccess = 0; --Error		
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END