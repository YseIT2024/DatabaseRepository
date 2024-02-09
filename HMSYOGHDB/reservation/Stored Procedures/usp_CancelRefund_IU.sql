CREATE PROC [reservation].[usp_CancelRefund_IU]
	
	@RefundId int,
	@CancellationId int,
	@refundDate datetime,
    @refundMode int,
	@refundAmount decimal,
	@GuestId int,
	@guestname nvarchar(50),
	@CancellationMode nvarchar(50),
	@Address nvarchar(50),
	@cancellationDate datetime,
    @userId int,   
	@LocationID int,
	@ReservationId int=null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		--DECLARE @ContactID int;
		--DECLARE @GenderID int;
		--Declare @ImageID int;
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		--DECLARE @Title varchar(200);
		--DECLARE @Actvity varchar(max);  
  

		BEGIN TRY	
		BEGIN TRANSACTION
			--IF EXISTS
			--	(SELECT * FROM [reservation].[Refund] WHERE RefundId = @RefundId)
				--Begin
				--UPDATE [reservation].[Refund]
				--   --SET [RefundId]=@RefundId,				      					 
				--	   SET [CancellationID] = @CancellationId, 
				--	   [CancellationMode]=@CancellationMode,
				--	   [CancellationDate]=@cancellationDate,
				--	   [ReservationId]=@ReservationId,
				--	   [GuestId]=@GuestId,
				--	   [GuestName]=@guestname,
				--	   [Address]=@Address,
				--	   [RefundDate] = @refundDate, 
				--	   [TransactionModeID]=@refundMode,
				--	   [ModifiedOn]=GETDATE(),
				--	   [ModifiedBy]=@userId
				-- WHERE [RefundId] = @RefundId
				--SET @IsSuccess = 1; --success 
				----SET @Message = 'Updated successfully.';
				--end
				  IF EXISTS (SELECT * FROM [reservation].[Refund] WHERE CancellationID = @CancellationId)
                  BEGIN
                     SET @Message = 'Refund transaction already exists.';
                  END
			ELSE

				Begin
				INSERT INTO [reservation].[Refund]([CancellationID],[CancellationMode],
				[CancellationDate],[ReservationId],[GuestId],[GuestName],[Address],
				   [CreatedOn],[CreatedBy],[RefundDate],[TransactionModeID],[RefundAmount])
			 VALUES
				   (@CancellationId,@CancellationMode,@cancellationDate,@ReservationId,
				   @GuestId,@guestname,@Address,getdate(),@userId,@refundDate,@refundMode,@refundAmount)
				  

				SET @RefundId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Inserted successfully.'
				
				end
			EXEC [app].[spInsertActivityLog] 7,@LocationID,@userId
	COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END; 		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@userId	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
