
CREATE PROC [Housekeeping].[usp_HKMiniBarItem_IU]
			
@ItemID int,
@ItemName varchar(100),
@ItemUOM  int,
@ItemRate decimal(18,2),
@ValidFrom datetime,
@ValidTo datetime,
@IsActive bit,
@userId int,   
@LocationID int,
@ServicTypeId int=null,
@Description varchar(150)
			
AS 

BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = @ItemName;
	DECLARE @ContactID int;	
	DECLARE @ReservationID int = 0;	
	DECLARE @DiscountID int = NULL;	
	DECLARE @RoomID int;		
	DECLARE @OutPutMSG varchar(500);
	DECLARE @OrdereDate datetime =GETDATE();
	DECLARE @ItemPriceID int = 0;	
	
	DECLARE @LocationCode VARCHAR(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);		

	--select * from [service].[Item]

	BEGIN TRY		
		BEGIN TRANSACTION							
					IF(@ItemID=0)						
						IF EXISTS 
							(SELECT * FROM [service].[Item] WHERE [Name] = @ItemName)
							Begin								
								SET @IsSuccess = 1; --success
								SET @Message = 'Item Name already exisits' ;
							end
						else
							BEGIN
							--Insert into Service Item
							INSERT INTO [service].[Item]
								([ServiceTypeID], [FoodTypeID], [Name], [ItemNumber], [Description], [Note], [LocationID], [IsAvailable],UOMID)
							VALUES(@ServicTypeId, NULL, @ItemName, 1, @Description, NULL, @LocationID, @IsActive,@ItemUOM)
						
							SET @ItemID = SCOPE_IDENTITY();

							INSERT INTO [service].[ItemPrice]
									   ([ItemID],[ItemRate],[ValidFrom],[ValidTo]
									   ,[IsActive],[CreatedBy],[CreatedOn],[Discount])
									   VALUES
									   (@ItemID,@ItemRate,@ValidFrom,@ValidTo,1, @userId,GETDATE(),0)							  


							SET @IsSuccess = 1; --success
							--SET @Message = 'New Item has been created successfully for <b>' + @Message + '</b>';
							SET @Message = 'New Item has been created successfully' ;

							END
					ELSE
						BEGIN
						if(@ItemID>1)
						BEGIN
							
							Update [service].[Item] SET
								[Description]=@Description, [IsAvailable]=@IsActive
								where ItemID=@ItemID
							

						select top(1) @ItemPriceID=ItemPriceId from [service].[ItemPrice] where [ItemID]=@ItemID and [IsActive]=1

						--select top(1) ItemPriceId from [service].[ItemPrice] where [ItemID]=251 and [IsActive]=1

						--select * from [service].[Item] where [ItemID]=251

						UPDATE [service].[ItemPrice] set [IsActive]=0 where ItemPriceId=@ItemPriceId

						INSERT INTO [service].[ItemPrice]
									   ([ItemID],[ItemRate],[ValidFrom],[ValidTo]
									   ,[IsActive],[CreatedBy],[CreatedOn],[Discount])
									   VALUES
									   (@ItemID,@ItemRate,@ValidFrom,@ValidTo,1, @userId,GETDATE(),0)

					    SET @IsSuccess = 1; --success
						SET @Message = 'Item details updated successfully ';
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
			SET @ItemID = -1; --error
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @ItemID AS [FolioNumber],@ReservationID as [ReservationID]
END


--SELECT * FROM [service].[Item]
