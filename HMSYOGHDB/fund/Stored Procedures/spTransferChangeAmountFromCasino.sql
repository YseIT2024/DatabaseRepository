-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spTransferChangeAmountFromCasino] 
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

	--DECLARE @LocationID INT = 
	--(
	--	SELECT LocationID FROM general.Location
	--	WHERE LocationCode = @Location
	--)

	--DECLARE @DrawerID INT=
	--(
	--	SELECT TOP 1 DrawerID FROM app.Drawer
	--	WHERE LocationID = @LocationID
	--)

	--DECLARE @AccountingDateId INT =
	--(
	--	SELECT  [account].[GetAccountingDateIsActive](@DrawerID)
	--);
	
	BEGIN TRY  
		BEGIN TRANSACTION		
			
			UPDATE fund.Flow SET 
			FundFlowStatusID = 7,
			TransferredBy = CONCAT(@UserName, '(', CAST(@UserID AS VARCHAR(10)),')'),
			TransferredOn = GETDATE()
			WHERE FundFlowID = @FundFlowID

			SET @IsSuccess = 1; --success  			
			SET @Message = 'Change amount has been transferred successfully.';
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
			SET @Message = 'Change amount has been transferred successfully.';			
		END;  

	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


