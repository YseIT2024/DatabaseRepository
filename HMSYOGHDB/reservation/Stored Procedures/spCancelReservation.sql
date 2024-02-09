
CREATE PROCEDURE [reservation].[spCancelReservation]
(	
	@ReservationID int,
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
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID)
	Declare @DateDifference int, @Nights int, @FolioNumber int
	Declare @CancellationPercent decimal(18,4);
	Declare @ReservationStatusID int;
	Declare @ExpectedCheckIn Datetime;


	--------------------------------------------
	--select @Nights = Nights  from  [reservation].[Reservation] where ReservationID = @ReservationID
	--set @DateDifference=DATEDIFF(DAY,GETDATE(),@RequestedOn)


	--SELECT @CancellationPercent = isnull(min(CancellationPercent),100)  FROM  [reservation].[StandardCancellationCharges]
	--			where  (@DateDifference >=CancellationDayFrom and @DateDifference <=CancellationDayTo)
	--			      and (@Nights >= NightsFrom and @Nights <= NightsTo)


					  ----RequiredAMT ?
					  --label_CancellationFee.Text = string.Format("{0:#,##0.00}", (page.RequiredAMT * model.CancellationFeePercent) / 100);
					  --label_RefundAmt.Text = (page.Advance - Convert.ToDecimal(label_CancellationFee.Text)).ToString();

	-----------------------------------------------------

	IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID) in (1,12))
	BEGIN
		BEGIN TRY  
			BEGIN TRANSACTION

			select @ExpectedCheckIn = ExpectedCheckIn , @ReservationStatusID = ReservationStatusID from reservation.Reservation WHERE ReservationID = @ReservationID
				if (@ReservationStatusID = 1 and DATEDIFF(DAY, (@ExpectedCheckIn), GETDATE()) > 0)
				Begin
						SET @ReservationStatusID = 15 --No Show
						SET @Message = 'No-Show done successfully.';

						SELECT @FolioNumber = (Select FolioNumber FROM reservation.Reservation WHERE ReservationID = @ReservationID)
					DECLARE @Acts VARCHAR(MAX) ='No-Show done successfully for ReservationID- '+ Cast(@ReservationID AS Varchar(20))+', FolioNo- '+ Cast(@FolioNumber AS Varchar(20)) + ' And Status changed to "No-Show". The Expected Checkin was- '+Cast(@ExpectedCheckIn AS Varchar(20))+ ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' By UserID- '+ Cast(@UserID AS Varchar(20))+' .' ;
					EXEC [app].[spInsertActivityLog]37,@LocationID,@Acts,@UserID, @Message
				END
				Else 
				Begin
					SET @ReservationStatusID = 2 --Cancelled
					SET @Message = 'Reservation has been canceled successfully.';
				End

				UPDATE [reservation].[Reservation]
				SET ReservationStatusID = @ReservationStatusID			
				WHERE ReservationID = @ReservationID

				INSERT INTO [reservation].[CancellationDetail]
				([ReservationID], [ReservationStatusID], [CancellationModeID],[CancellationCharge], [Refund], [CreatedBy],[CreatedDate], [Reason], [RequestedOn])
				VALUES(@ReservationID, @ReservationStatusID,  @CancellationModeID, @CancellationCharge, @Refund, @UserID, GETDATE(), @Reason, @RequestedOn)

				INSERT INTO [reservation].[ReservationStatusLog]
				([ReservationID],[ReservationStatusID],[UserID],[DateTime],[Remarks])
				VALUES(@ReservationID, @ReservationStatusID, @UserID, GETDATE(),@Reason)

				UPDATE  [Products].[RoomLogs] SET [RoomStatusID]=1 	WHERE ReservationID = @ReservationID 

				SET @IsSuccess = 1; --Success
				--SET @Message = 'Reservation has been canceled successfully.';

				SELECT @FolioNumber = FolioNumber FROM reservation.Reservation WHERE ReservationID = @ReservationID

				DECLARE @Title varchar(200) = 'Cancel Reservation for ReservationID- '+ Cast(@ReservationID AS Varchar(20))+ ' and Folio No- '  + (SELECT CONCAT(@Location, FolioNumber) FROM reservation.Reservation WHERE ReservationID = @ReservationID) 
				+ ' has been completed successfully. '
				DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + ' By UserID- '+ Cast(@UserID AS Varchar(20));
				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
			COMMIT TRANSACTION

			EXEC [app].[spInsertActivityLog]36,@LocationID,@NotDesc,@UserID,@Message
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
			EXEC [app].[spInsertActivityLog]36,@LocationID,@Act,@UserID, @Message
		END CATCH;  
	END
	ELSE
		BEGIN
			SET @Message = 'An error occurred in database please refresh the page';
			SET @IsSuccess = 0; --Error		
		END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message],@FolioNumber as FolioNumber
END









