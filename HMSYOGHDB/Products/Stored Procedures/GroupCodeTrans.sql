

CREATE Proc [Products].[GroupCodeTrans]
(
	@GroupId int,
	@GroupCode varchar(50),
	@CategoryID int,
	@GroupDescription varchar(155),
	@User INT
)
AS
BEGIN

	--Declare 
	--@GroupId int,
	--@GroupCode varchar(50),
	--@CategoryID int,
	--@GroupDescription varchar(155),
	--@User INT

	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @Title varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';	

	BEGIN TRY		
		BEGIN TRANSACTION
			BEGIN
			 IF(@GroupId<=0)    
				BEGIN
					IF(EXISTS(SELECT GroupCode FROM Products.Groups WHERE GroupCode=@GroupCode))
						BEGIN						 
							SET @Message = 'Group Code  already exists.';
							SET @IsSuccess = 0; 
						END
					ELSE
						BEGIN
							INSERT INTO Products.Groups(GroupCode,Description,CategoryID,CreatedBy,CreatedDate)
							VALUES(@GroupCode,@GroupDescription,@CategoryID,@User,GETDATE())

							SET @Message = 'Group code added successfully.';
							SET @IsSuccess = 1; --success
					
							SET @Title = 'Group code: ' + @GroupCode + ' added successfully';
							SET @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@User as varchar(10));
							EXEC [app].[spInsertActivityLog]27,1,@Title,@User
						END
				END
			ELSE
				BEGIN
					UPDATE Products.Groups 
					SET GroupCode=@GroupCode,
						Description=@GroupDescription,
						CategoryID=@CategoryID,
						CreatedBy=@User,
						CreatedDate=GETDATE()
						where GroupID=@GroupId

							SET @Message = 'Group code Updated successfully.';
							SET @IsSuccess = 1; --success

							SET @Title = 'Group code: ' + @GroupCode + ' Updated successfully';
							EXEC [app].[spInsertActivityLog]27,1,@Title,@User
				END
			END
				
			
				
		COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  

			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;    
    
		--IF (XACT_STATE() = 1)  
		--BEGIN  			
		--	COMMIT TRANSACTION;   
		--	SET @IsSuccess = 1; --success 			
		--END;  
		
		----------------Insert into activity log----------------------	
		--DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		--EXEC [app].[spInsertActivityLog]25,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END

