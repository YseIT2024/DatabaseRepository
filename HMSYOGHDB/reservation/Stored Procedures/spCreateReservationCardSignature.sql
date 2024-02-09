
CREATE PROCEDURE [reservation].[spCreateReservationCardSignature](		
	@ReservationID int,
	@CardSignature nvarchar(max),
	@GuestName nvarchar(150),
	@SignatureUser nvarchar(150)
 
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
 

	BEGIN TRY	
				  
		INSERT INTO [reservation].[GuestSignature]
		([InvoiceNo],[GuestSignature],[GuestName],[DateTime],[GuestSignatureTypeID])
		VALUES
		(@ReservationID,@CardSignature,@GuestName,getdate(),2)
				 
		SET @IsSuccess = 1; 				
		SET @Message = 'guest signature created successfully' ;
				  
	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			--SET @FolioNumbers = -1; --error
		END;    
		
		--IF (XACT_STATE() = 1)  
		--BEGIN  			
		--	COMMIT TRANSACTION;   
		--	SET @IsSuccess = 1; --success  
		--	SET @Message = 'Invoice has been created successfully for ' + @FolioNumber;
		--END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		--EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
