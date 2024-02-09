-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [person].[spSavePersonDocument] 
(
	@ContactID int,
	@DocumentTypeID int,
	@Extnsn varchar(10),
	@IsEmployee bit,
	@UserID int,
	@LocationID int	
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250) = '';
	DECLARE @DocName varchar(200);
	DECLARE @DocumentID int;
	
	BEGIN TRY  
		BEGIN TRANSACTION
			
			SET @DocName = CASE WHEN @IsEmployee= 1 THEN 'Employee\' ELSE 'Guest\' END 
			+ CAST(@ContactID AS VARCHAR)+ '_' +  CAST(@DocumentTypeID AS VARCHAR) + '_' + (SELECT FORMAT(GETDATE(),'ddMMyyhhmmssff')) + @Extnsn

			INSERT INTO [general].[Document]
					([IDCardTypeID]
					,[DocumentUrl] 
					,[UserID]
					,[IsActive])
				VALUES
					(@DocumentTypeID
					,@DocName 
					,@UserID
					,1)

			SET @DocumentID = SCOPE_IDENTITY();

			INSERT INTO [contact].[Document]
					   ([ContactID]
					   ,[DocumentID])
					VALUES
						(@ContactID
						,@DocumentID)
			
			SET @IsSuccess = 1; --success  			
			SET @Message = @DocName;

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
			SET @Message = @DocName;
		END;  	
	END CATCH;				

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END
