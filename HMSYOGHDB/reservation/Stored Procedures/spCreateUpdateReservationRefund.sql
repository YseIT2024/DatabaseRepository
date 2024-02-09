
CREATE PROCEDURE [reservation].[spCreateUpdateReservationRefund]
(	
	--@RefundId int ,
	@RefundDate datetime = NULL,
	@CancellationID int,
	@TransactionModeID int = NULL,
	@CreatedOn datetime = NULL,
	@CreatedBy int = NULL,
	@ModifiedOn datetime = NULL,
	@ModifiedBy int = NULL,
	@RefundAmount decimal(18, 0),
	@CancellationMode nvarchar(50) = NULL,
	@CancellationDate datetime = NULL,
	@ReservationId int ,
	@GuestId int = NULL,
	@GuestName nvarchar(50) = NULL,
	@Address nvarchar(50) = NULL
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Drawer varchar(20);
	--Declare @SupplierNo varchar(50)

 
	BEGIN TRY		
			BEGIN TRANSACTION			

				IF NOT EXISTS(SELECT 1 FROM reservation.Refund WHERE ReservationId= @ReservationId AND  CancellationID = @CancellationID)
				BEGIN
					--SET @RefundId = SCOPE_IDENTITY();


					insert into reservation.Refund
					(
					--RefundId, 
					RefundDate, 
					CancellationID, 
					TransactionModeID, 
					CreatedOn,
					CreatedBy,
					ModifiedOn, 
					ModifiedBy, 
					RefundAmount,
					CancellationMode,
					CancellationDate,
					ReservationId, 
					GuestId, 
					GuestName, 
					Address
					)
					values
					(
					--@RefundId, 
					@RefundDate, 
					@CancellationID, 
					@TransactionModeID, 
					@CreatedOn,
					@CreatedBy,
					@ModifiedOn, 
					@ModifiedBy, 
					@RefundAmount,
					@CancellationMode,
					@CancellationDate,
					@ReservationId, 
					@GuestId, 
					@GuestName, 
					@Address
					)
					SET @Message = 'Refund Details has been saved successfully.';
				END
				ELSE
				BEGIN

					UPDATE reservation.Refund
					SET
					--@RefundId=RefundId
					@RefundDate=RefundDate
					--,@CancellationID=CancellationID
					,@TransactionModeID=TransactionModeID
					,@CreatedOn=CreatedOn
					,@CreatedBy=CreatedBy
					,@ModifiedOn=ModifiedOn
					,@ModifiedBy=ModifiedBy
					,@RefundAmount=RefundAmount
					,@CancellationMode=CancellationMode
					,@CancellationDate=CancellationDate
					--,@ReservationId=ReservationId
					,@GuestId=GuestId
					,@GuestName=	GuestName
					,@Address=Address

					WHERE ReservationId= @ReservationId 
					AND CancellationID = @CancellationID

					SET @Message = 'Refund detail has been updated successfully.';
				END						

				SET @IsSuccess = 1; --success
				
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
			IF NOT EXISTS(SELECT 1 FROM reservation.Refund WHERE ReservationId= @ReservationId AND  CancellationID = @CancellationID)
			BEGIN 
				SET @Message = 'Refund detail has been added successfully.';
			END
			ELSE
			BEGIN
				SET @Message = 'Refund detail been updated successfully.';
			END
		END  ;
	END CATCH	

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END

