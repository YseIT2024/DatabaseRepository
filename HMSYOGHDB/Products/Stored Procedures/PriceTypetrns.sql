

CREATE Proc [Products].[PriceTypetrns]
(
	@PriceTypeID int,
	@Discount varchar(10),
	@Remarks varchar(200),
	@UserID int,
	@LocationID int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';	

	BEGIN TRY		
		BEGIN TRANSACTION			
			--Update				

					UPDATE  [Products].[PriceType]
					SET [Remarks] = @Remarks, [Discount] = @Discount
					WHERE [PriceTypeID] = @PriceTypeID						

					SET @Message = 'Price Type updated successfully.';
					SET @IsSuccess = 1; --success

					SET @Title = 'PriceType: ' + STR(@PriceTypeID) + ' updated';
					SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					
	     			EXEC [app].[spInsertActivityLog]8,@LocationID,@Title,@UserID
				
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
		END;  
		
		--------------Insert into activity log----------------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]8,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

