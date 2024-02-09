
CREATE Proc [room].[RoomTrans]
(
    @RoomID int,
	@RoomNo int,
	@SubCategoryID int,
	@FloorID int,	
	@LocationID int,
	@MaxCapacity int,
	@MaxChildCapacity int,
	@RoomSize varchar(50) = null,
	@BedSize varchar(20) = null,
	@Remarks varchar(200) = null,
	@IsActive bit,
	@RoomStatusID int,
	@UserID int
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
	DECLARE @Act varchar(250);
	declare @OnlineListing int
	declare @TotalInventory int
	IF(@RoomID <=0)
		IF EXISTS(SELECT RoomID FROM Products.Room WHERE RoomNo = @RoomNo AND LocationID = @LocationID )
			BEGIN
				SET @Message = 'Room number already exists. Please insert unique room number.'
			END
		ELSE
			BEGIN
				
					INSERT INTO Products.room	
					([RoomNo],SubCategoryID, [FloorID],[LocationID], MaxAdultCapacity,MaxChildCapacity,Dimension ,BedSize ,RoomStatusID,Remarks,IsActive,CreatedBy,CreateDate)				
					VALUES(@RoomNo, @SubCategoryID, @FloorID, @LocationID, @MaxCapacity,@MaxChildCapacity,@RoomSize,@BedSize, @RoomStatusID,@Remarks,@IsActive,@UserID,GETDATE())

				   IF(@IsActive=1)
				   BEGIN
					     update [Products].[SubCategory] SET TotalInventory=TotalInventory+1 where SubCategoryID= @SubCategoryID
				   END

					SET @IsSuccess = 1;
					SET @Message = 'New room has been saved successfully.'
						---------------------------- Insert into activity log---------------	
			SET @Act = @Message--(SELECT app.fngeterrorinfo());		
		    EXEC [app].[spInsertActivityLog]15,@LocationID,@Act,@UserID	
			END 
	ELSE
		BEGIN
		IF EXISTS(SELECT RoomID FROM Products.Room WHERE RoomNo = @RoomNo AND LocationID = @LocationID AND RoomID <> @RoomID )
			BEGIN
				SET @Message = 'Room number already exists. Please insert unique room number.'
			END
	   ELSE
	   BEGIN
		  Update Products.Room SET
			 RoomNo = @RoomNo,
			 SubCategoryID = @SubCategoryID,
			 FloorID = @FloorID,
			 LocationID = @LocationID,
			 MaxAdultCapacity = @MaxCapacity,
			 MaxChildCapacity = @MaxChildCapacity,
			 Dimension = @RoomSize,
			 BedSize = @BedSize,
			 RoomStatusID = @RoomStatusID,
			 Remarks = @Remarks,
			 IsActive = @IsActive,
			 CreatedBy = @UserID,
			 CreateDate = GETDATE()
			 where RoomID=@RoomID 

			 IF(@IsActive=0)
			 BEGIN
			 update [Products].[SubCategory] SET TotalInventory=TotalInventory-1 where SubCategoryID= @SubCategoryID 
			 select @OnlineListing=Online_listing,@TotalInventory=TotalInventory from  [Products].[SubCategory] where SubCategoryID= @SubCategoryID 

			 if(@OnlineListing>@TotalInventory)
			 Begin
				update  [Products].[SubCategory] SET Online_Listing -=1 where SubCategoryID= @SubCategoryID 
			 end
			 END
			 ELSE
			 BEGIN
			  update [Products].[SubCategory] SET TotalInventory=TotalInventory+1 where SubCategoryID= @SubCategoryID 
			 END

			 SET @IsSuccess = 1;
			 SET @Message = 'Room has been Updated successfully.'
			 	---------------------------- Insert into activity log---------------	
			SET @Act = @Message--(SELECT app.fngeterrorinfo());		
		    EXEC [app].[spInsertActivityLog]15,@LocationID,@Act,@UserID	
			END
		END
		
	

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END



