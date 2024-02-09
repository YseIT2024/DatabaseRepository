
create PROCEDURE [reservation].[spCreateDigitalSignatureWeb](		
	@GuestSignatureID int,
	@InvoiceNo int,
	@GuestSugnature nvarchar(max),
	@GuestName nvarchar(150),
	@SignatureUser nvarchar(150),
	@ManagerSignature nvarchar(max)
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
 

	BEGIN TRY	

		IF NOT EXISTS (SELECT * FROM [reservation].[GuestSignature] where [InvoiceNo]=@InvoiceNo)
			BEGIN
				BEGIN TRANSACTION		
					 BEGIN
						INSERT INTO [reservation].[GuestSignature]
							   ([InvoiceNo],[GuestSignature],[GuestName],[DateTime],[ManagerSignature])
						 VALUES
							   (@InvoiceNo,@GuestSugnature,@GuestName,getdate(),@ManagerSignature)
					END
					SET @IsSuccess = 1; 				
				SET @Message = 'signature created successfully' ;
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				BEGIN TRANSACTION		
					 BEGIN
						UPDATE [reservation].[GuestSignature]
							   SET [InvoiceNo]=@InvoiceNo,
								   [GuestSignature]=@GuestSugnature,
								   [GuestName]=@GuestName,
								   [ModifiedDateTime]=getdate(),
								   [ManagerSignature]=@ManagerSignature
								   where [InvoiceNo]=@InvoiceNo
					END
					SET @IsSuccess = 1; 				
				SET @Message = 'signature created successfully' ;
				COMMIT TRANSACTION
			END
	
	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			--SET @FolioNumbers = -1; --error
		END;    
		
		 
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		--EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END



