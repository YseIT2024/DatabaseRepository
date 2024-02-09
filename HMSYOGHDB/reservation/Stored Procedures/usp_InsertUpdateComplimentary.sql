CREATE PROC [reservation].[usp_InsertUpdateComplimentary]    
    @LedgerId int,
	@IsComplimentary bit,
	@ComplimentaryPercentage decimal(18,2),
    @UserID int=0,
    @LocationId int=1
 
AS 

BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX);

	BEGIN TRY

    BEGIN TRAN
	
	             Update [account].[GuestLedgerDetails] SET IsComplimentary=@IsComplimentary,ComplimentaryPercentage= @ComplimentaryPercentage  where LedgerId=@LedgerId

				  SET @Message = 'Saved Successfully';
				  SET @IsSuccess = 1;	
		
    COMMIT
	END TRY
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --Error			
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   

			SET @IsSuccess = 1; --Success  			
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess [IsSuccess], @Message [Message]
END

--871
--SELECT * FROM [account].[GuestLedgerDetails] where LedgerId=871