
CREATE PROCEDURE [reservation].[spComplementaryService_IU] 
(
	@FolioNo INT,
	@ReservationID INT,	
	@LocationID INT,
	@DrawerID INT,
	@UserID INT
	--@dtRate as reservation.dtRoomRate READONLY		
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	
	DECLARE @LedgerId INT;
	DECLARE @ServiceId INT;
	DECLARE @IsActive INT; 
	DECLARE @CreatedBy INT;
	DECLARE @CreatedOn INT;
	DECLARE @ModifiedBy INT;
	DECLARE @ModifiedOn INT;
	
	
	BEGIN TRY
		BEGIN TRANSACTION	

		INSERT INTO [reservation].[ComplementaryService]
			   ([FolioNo],[LedgerId],[ServiceId],[IsActive]
			   ,[CreatedBy],[CreatedOn],[ModifiedBy],[ModifiedOn])
		 VALUES
			   (@FolioNo,@LedgerId,@ServiceId,@IsActive, 
			   @CreatedBy,@CreatedOn,@ModifiedBy,@ModifiedOn)			

						
				SET @IsSuccess = 1; --success
				SET @Message = 'Complementary Services marked';		
							
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
				SET @Message = 'Complementary Services marked';
			END;  		
		
		END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]	
END
