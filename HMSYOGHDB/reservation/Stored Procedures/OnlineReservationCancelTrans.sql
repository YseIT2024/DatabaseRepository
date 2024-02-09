

CREATE Proc [reservation].[OnlineReservationCancelTrans]
(
	@ReservationID int,
	@Reason varchar(200) 
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
	DECLARE @LocationID int = 0;

	BEGIN TRY		
		BEGIN TRANSACTION				
		

					IF(EXISTS(SELECT [ReservationID] FROM [reservation].[Reservation] WHERE [ReservationID] = @ReservationID ))
					BEGIN

						SET @LocationID = (SELECT LocationID FROM [reservation].[Reservation] WHERE [ReservationID] = @ReservationID);

						UPDATE [reservation].[Reservation]
						SET [ReservationStatusID] = 2
						WHERE [ReservationID] = @ReservationID				

						SET @Message = 'Reservation Cancelled Successfully.';
						SET @IsSuccess = 1; --success

						SET @Title = 'Online Reservation: ' + STR( @ReservationID) + ' Cancelled';
						SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') ;
					
	     				EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	

					END
					ELSE
					BEGIN
						SET @Message = 'Reservation not found.';
						SET @IsSuccess = 0;
					

				END
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
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,null	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message],@ReservationID as ReservationID
END

