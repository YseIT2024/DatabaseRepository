CREATE PROCEDURE [guest].[usp_SoftDelete_IU] 
(	
	@GUESTID int,
	@REASON varchar(100),
	@SDSTATUS varchar(100),	
	@USERID int,
	@MODIFIEDON datetime,	
	@IsActive int,	
	@LocationID int,
	@IsRollBack int=Null
)

AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess BIT = 0;
	DECLARE @Message VARCHAR(MAX);

	BEGIN TRY  
		BEGIN TRANSACTION

					IF NOT EXISTS(SELECT CUSTOMERID FROM [guest].[SoftDelete] WHERE CUSTOMERID =@GuestID)
						BEGIN
							INSERT INTO [guest].[SoftDelete]
								   ([CUSTOMERID],[REASON],[SDSTATUS],[CREATEDON],[CREATEDBY],[IsActive])
							 VALUES
								   (@GUESTID,@REASON,@SDSTATUS,getdate(),@USERID,@IsActive)
							
							SET @Message = 'Customer Soft Deleted Successfully';
							SET @IsSuccess = 1;							
						END
					ELSE if @IsRollBack>0
					    BEGIN 									
						DELETE FROM [guest].[SoftDelete] WHERE CUSTOMERID=@GUESTID
						--UPDATE [guest].[SoftDelete]
						--		SET [REASON]=@REASON,								
						--			[SDSTATUS]=@SDSTATUS,
						--			[MODIFIEDON]  = getdate(),
						--			[MODIFIEDBY] =@USERID,
						--			[IsActive]=@IsActive
						--		WHERE [CUSTOMERID]=@GuestID
						SET @Message = 'Customer removed from soft delete';
						--	SET @Message = 'Customer Status Updated Successfully';
							SET @IsSuccess = 1; 
					    END 
			
		COMMIT TRANSACTION; 
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



