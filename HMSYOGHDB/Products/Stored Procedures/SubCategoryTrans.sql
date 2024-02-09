
CREATE PROCEDURE  [Products].[SubCategoryTrans] 
(
@CategoryID int,
@SubCategoryID int,
@Code varchar(50),
@Name varchar(100),
@Description varchar(500)=null,
@Remarks varchar(200)=null,
@CreatedBy int,
@AcceptOnlineReservations int=0,
@IsAcive int=0--Added Rajendra
)
AS
BEGIN
    DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @Title varchar(200);
	DECLARE @Actvity varchar(max);
	IF(@SubCategoryID <= 0)
	BEGIN
	    IF NOT EXISTS(Select Code from Products.SubCategory where Code=@Code and [Name]=@Name)
		BEGIN
	    Insert Into Products.SubCategory ([CategoryID],[Code],[Name],[Description],[Remarks],[CreatedBy],[CreateDate],IsActive,AcceptOnlineReservations)
		                                    Values (@CategoryID,@Code,@Name,@Description,@Remarks,@CreatedBy,GETDATE(),@IsAcive,@AcceptOnlineReservations)--IsAcive Added Rajendra
          SET @IsSuccess=1;
		  SET @Message= 'SubCategory Added Successfully';

		  --      SET @Title  = 'Subcategory: ' + @Code + ' ' + @Description + ' has added'
				--SET @Actvity = @Title +' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@CreatedBy as varchar(10));
				--EXEC [app].[spInsertActivityLog] 7,0, @Actvity,@CreatedBy
				SET @Actvity = @Message--(SELECT app.fngeterrorinfo());		
		    EXEC [app].[spInsertActivityLog]26,0,@Actvity,@CreatedBy	
	    END
		ELSE
		BEGIN
		   SET @Message=  'Code Already Exists';
		END
	END
	ELSE
	BEGIN
	   IF NOT EXISTS(Select Code from Products.SubCategory where Code=@Code and [Name]=@Name and SubCategoryID <> @SubCategoryID)
	   BEGIN
		   Update Products.SubCategory 
		   SET  [CategoryID] = @CategoryID,
				[Code] = @Code ,
				[Name] = @Name ,
				[Description] = @Description,
				[Remarks] = @Remarks ,
				[CreatedBy] = @CreatedBy,
				[CreateDate] = GETDATE(),
				[AcceptOnlineReservations]=@AcceptOnlineReservations,
				[IsActive]=@IsAcive--Added Rajendra
				Where SubCategoryID=@SubCategoryID
			  SET @IsSuccess=1;
			  SET @Message= 'SubCategory Updated Successfully';
			  SET @Actvity = @Message--(SELECT app.fngeterrorinfo());		
		    EXEC [app].[spInsertActivityLog]26,0,@Actvity,@CreatedBy	
		 END
	END
	SELECT @IsSuccess AS IsSuccess, @Message as [Message]
END