CREATE procedure [dbo].[spTest]
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
  
	BEGIN TRY  
		BEGIN TRANSACTION;  
			-- A FOREIGN KEY constraint exists on this table. This   
			-- statement will generate a constraint violation error.  
			DELETE FROM contact.Details WHERE ContactID = 1;  
		
			PRINT N'Skip'	
			-- If the DELETE statement succeeds, commit the transaction.  
		COMMIT TRANSACTION;  
	END TRY  
	BEGIN CATCH    
		-- Test XACT_STATE:  
		-- If 1, the transaction is committable.  
		-- If -1, the transaction is uncommittable and should   
		--     be rolled back.  
		-- XACT_STATE = 0 means that there is no transaction and  
		--     a commit or rollback operation would generate an error.  
  
		-- Test whether the transaction is uncommittable.  
		IF (XACT_STATE() = -1) 
		BEGIN  
			PRINT N'The transaction is in an uncommittable state.' + 'Rolling back transaction.'  
			ROLLBACK TRANSACTION;  
		END;  
  
		-- Test whether the transaction is committable.  
		IF (XACT_STATE() = 1)  
		BEGIN  
			PRINT N'The transaction is committable.' + 'Committing transaction.'  
			COMMIT TRANSACTION;     
		END;  

		-- Execute error retrieval routine.  
		declare @msg varchar(max) = (select app.fngeterrorinfo());
		exec [app].[spInsertActivityLog] 3, 1, @msg
	END CATCH;  
END










