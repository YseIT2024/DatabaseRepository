
-- =============================================
-- Author:		<Arabinda>
-- Create date: <3/30/2023 7:35:49 PM>
-- Description:	<To Add Update Guest to Blacklist and undo the same>
-- =============================================

CREATE PROCEDURE [guest].[usp_Blacklist_IU] 
(	
	@GuestID INT,
	@REASON VARCHAR(100),
	@BLTYPEID INT,
	@EFFECTIVEFROM DATETIME,
	@REQUESTEDBY INT,
	@BLSTATUS VARCHAR(30),
	@REMOVEDDATE DATETIME,
	@REMOVEDBY INT,
	@CREATEDON DATETIME,
	@UserID INT,
	@MODIFIEDON DATETIME,	
	@IsActive INT,
	@LocationID INT
)
AS
BEGIN
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX);

	BEGIN TRY  
		IF @BLTYPEID = 1 -- Alert only
		BEGIN
		BEGIN TRANSACTION;
		INSERT INTO [guest].[Blacklist]
				(
					[CUSTOMERID],[REASON],[BLTYPEID],[EFFECTIVEFROM],
					[REQUESTEDBY],[BLSTATUS],[CREATEDON],[CREATEDBY],[IsActive]
				)
				VALUES
				(
					@GuestID, @REASON, @BLTYPEID, @EFFECTIVEFROM,
					@REQUESTEDBY, @BLSTATUS, @CREATEDON, @UserID, @IsActive
				);
			SET @Message = 'Customer Alerted Successfully.';
			SET @IsSuccess = 1;
			COMMIT TRANSACTION;
		END
		ELSE IF @BLTYPEID = 2 -- Alert and block
		BEGIN
			IF NOT EXISTS (SELECT CUSTOMERID FROM [guest].[Blacklist] WHERE CUSTOMERID = @GuestID and [BLTYPEID]=@BLTYPEID)
			BEGIN
				BEGIN TRANSACTION;
				INSERT INTO [guest].[Blacklist]
				(
					[CUSTOMERID],[REASON],[BLTYPEID],[EFFECTIVEFROM],
					[REQUESTEDBY],[BLSTATUS],[CREATEDON],[CREATEDBY],[IsActive]
				)
				VALUES
				(
					@GuestID, @REASON, @BLTYPEID, @EFFECTIVEFROM,
					@REQUESTEDBY, @BLSTATUS, @CREATEDON, @UserID, @IsActive
				);
				SET @Message = 'Customer Blacklisted and Alerted Successfully';
				SET @IsSuccess = 1;
				COMMIT TRANSACTION;
			END
			ELSE
			BEGIN
				SET @Message = 'Customer is already blocked';
				SET @IsSuccess = 0;
			END
		END
		ELSE IF @BLTYPEID = 3 -- Unblock
		BEGIN
			IF EXISTS (SELECT CUSTOMERID FROM [guest].[Blacklist] WHERE CUSTOMERID = @GuestID)
			BEGIN
				BEGIN TRANSACTION;
				INSERT INTO [guest].[Blacklist_History]
				SELECT TOP 1* FROM [guest].[Blacklist] WHERE [CUSTOMERID]=@GuestID
				--DELETE FROM [guest].[Blacklist] WHERE [CUSTOMERID] = @GuestID;
				UPDATE [guest].[Blacklist]
								SET [REASON]=@REASON,
								[BLTYPEID]=@BLTYPEID,
								[EFFECTIVEFROM]=@EFFECTIVEFROM,
								[REQUESTEDBY]=@REQUESTEDBY,
								[BLSTATUS]=@BLSTATUS,
								[CREATEDON]=@CREATEDON,
								[CREATEDBY]=@UserID,
								[IsActive]=@IsActive
							WHERE [CUSTOMERID]=@GuestID
				
				
				SET @Message = 'Customer has been unblocked';
				SET @IsSuccess = 1;
				COMMIT TRANSACTION;
			END
			ELSE
			BEGIN
				SET @Message = 'Customer is not blocked';
				SET @IsSuccess = 0;
			END
		END
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0;
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1;
		END;  
		
		-- Insert into activity log
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3, @LocationID, @Act, @UserID
	END CATCH;  

	SELECT @IsSuccess [IsSuccess], @Message [Message]
END