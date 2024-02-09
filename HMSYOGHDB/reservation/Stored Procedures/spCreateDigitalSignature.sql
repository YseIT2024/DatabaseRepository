
CREATE PROCEDURE [reservation].[spCreateDigitalSignature](		
	@GuestSignatureID int,
	@InvoiceNo int,
	@GuestSugnature nvarchar(max),
	@GuestName nvarchar(150),
	@SignatureUser nvarchar(150),
	@ManagerSignature nvarchar(max)=NULL
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
				 IF(@SignatureUser='Web')
				 BEGIN
					INSERT INTO [reservation].[GuestSignature]
					([InvoiceNo],[GuestSignature],[GuestName],[DateTime],[ManagerSignature])
					VALUES
					(@InvoiceNo,@GuestSugnature,@GuestName,getdate(),@ManagerSignature)

					Update [reservation].[InvoiceSignatureTickets] set [Status]=0
				 END
				 ELSE
				 BEGIN
				 
					IF(@SignatureUser = 'Guest')
					 BEGIN

						INSERT INTO [reservation].[GuestSignature]
							   ([InvoiceNo],[GuestSignature],[GuestName],[DateTime])
						 VALUES
							   (@InvoiceNo,@GuestSugnature,@GuestName,getdate())
					END
					IF(@SignatureUser = 'Manager')
					 BEGIN

						INSERT INTO [reservation].[GuestSignature]
							   ([InvoiceNo],[ManagerSignature],[GuestName],[DateTime])
						 VALUES
							   (@InvoiceNo,@GuestSugnature,@GuestName,getdate())
					END
					END
					SET @IsSuccess = 1; 				
				SET @Message = 'guest signature created successfully' ;
				COMMIT TRANSACTION
			END
		ELSE
			BEGIN
				BEGIN TRANSACTION		
				 IF(@SignatureUser='Web')
				 BEGIN
					UPDATE [reservation].[GuestSignature]
					SET [InvoiceNo]=@InvoiceNo,
					[GuestSignature]=@GuestSugnature,
					[GuestName]=@GuestName,
					[ModifiedDateTime]=getdate(),
					[ManagerSignature]=@ManagerSignature
					where [InvoiceNo]=@InvoiceNo
				 END
				 ELSE
				 BEGIN
				IF(@SignatureUser = 'Guest')
					 BEGIN
						UPDATE [reservation].[GuestSignature]
							   SET [InvoiceNo]=@InvoiceNo,
								   [GuestSignature]=@GuestSugnature,
								   [GuestName]=@GuestName,
								   [ModifiedDateTime]=getdate() where [InvoiceNo]=@InvoiceNo
					END

					IF(@SignatureUser = 'Manager')
					 BEGIN
						UPDATE [reservation].[GuestSignature]
							   SET [InvoiceNo]=@InvoiceNo,
								   [ManagerSignature]=@GuestSugnature,
								   [GuestName]=@GuestName,
								   [ModifiedDateTime]=getdate() where [InvoiceNo]=@InvoiceNo
					END
					END
					SET @IsSuccess = 1; 				
				SET @Message = 'guest signature created successfully' ;
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



