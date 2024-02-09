-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spConfirmHotelChanges] 
(
	@FundFlowID INT,	
	@UserID INT,
	@UserName VARCHAR(100)
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0
	DECLARE @Message VARCHAR(250);
	
	BEGIN TRY  
		BEGIN TRANSACTION		
			
			UPDATE fund.Flow SET 
			FundFlowStatusID = 6,
			ConfirmedBy = @UserID,
			ConfirmedOn = GETDATE()
			WHERE FundFlowID = @FundFlowID

			SET @IsSuccess = 1; --success  			
			SET @Message = 'Change amount has been confirmed successfully.';
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
			SET @Message = 'Change amount has been confirmed successfully.';			
		END;  

	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


