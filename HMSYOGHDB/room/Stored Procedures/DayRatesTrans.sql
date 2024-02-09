CREATE PROCEDURE [room].[DayRatesTrans] 
(
	@PriceID         int,
	@ItemID          int,
	@LocationID		 int,
	@BasePrice		 int,
	@BasePriceSingle int,
	@Commission		 int,
	@Discount		 int,
	@AddPax			 int,
	@AddChild		 int,
	@AddChildSr      int,
	@UserID			 int,
	@LogLocationID	 int,
	@SelectedDays AS [room].[SelectedDays] READONLY

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
	DECLARE @tempDays table (ID int identity(1,1), [Days] varchar(10));
	DECLARE @DayID int = 1;
	DECLARE @Count int;
	DECLARE @Day varchar(10)

		
	DECLARE @ProcessTypeId INT;
	DECLARE @ToUserId INT;
	DECLARE @DayRatesID INT;

	DECLARE @OldRate DECIMAL(18,2);
	DECLARE @Description nvarchar(250);

	INSERT INTO @tempDays SELECT SelectedDays from @SelectedDays
	select @Count = count(*) from @tempDays

	BEGIN TRY	
	
		BEGIN TRANSACTION	

			if(@PriceID = 0)--New entry
			BEGIN
				WHILE (@DayID <= @Count)
					BEGIN
						SELECT @Day = [Days] FROM @tempDays where [ID] = @DayID
						
						IF(EXISTS(select ItemID from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and [Day] = @Day))
							BEGIN
								--Commented by Arabinda on 21-07-2023 to keep history ------
								--Update [Products].[RoomDayPrice] set [BasePrice]=@BasePrice, [BasePriceSingle]=@BasePriceSingle ,
								--[Commission]=@Commission, [Discount]=@Discount, [AddPax]=@AddPax ,[AddChild]=@AddChild
								--where [ItemID] = @ItemID and [LocationID]= @LocationID and [Day] = @Day

								set @OldRate = (select BasePrice from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and [Day] = @Day and IsActive=1)
								if(@OldRate is null)
								begin
								set @OldRate=0
								end
								set @Description  = +'Item Code : '+(select top(1) ItemCode from Products.Item where ItemID=@ItemID)+', ' + @Day +' Room Rate Changed, From Rate '+ CONVERT(NVARCHAR, @OldRate , 0)+' and To Rate '+ CONVERT(NVARCHAR, @BasePrice, 0)+''
								--Modified by Arabinda on 21-07-2023 to keep history ------
								Update [Products].[RoomDayPrice] set IsActive=0,ModifiedBy=@UserID,ModifiedDate=getDate()
								where [ItemID] = @ItemID and [LocationID]= @LocationID and [Day] = @Day	 and IsActive=1								
								

								insert into [Products].[RoomDayPrice] ([ItemID],[LocationID],[Day],[BasePrice],[BasePriceSingle],[Commission],
									[Discount],[AddPax],[AddChild],[AddChildSr],[CreatedBy],[CreateDate],IsActive,AuthorizedFlag,IsRateChanged)
								values (@ItemID,@LocationID,@Day,@BasePrice,@BasePriceSingle,@Commission,@Discount,@AddPax,@AddChild,@AddChildSr,
									@UserID,getDate(),1,1,1)

									SET @DayRatesID = SCOPE_IDENTITY();	
									

									--- Insert Approval WorkFlow
									SET @ProcessTypeId=4;
									SET @ToUserId=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId ORDER BY ApprovalLevel ASC)

									EXEC [reservation].[spCreateUpdateAppravalForTransaction]@ProcessTypeId, @LocationID, @UserID, @DayRatesID, 0, NULL, NULL, @ToUserId, NULL,@Description,@OldRate,@BasePrice,0

									--- Insert Approval WorkFlow End - @ProcessTypeId, @LocationID, @UserID, @CurrencID, Status, ModifiedOn, ModifiedBy, @ToUserId, Remark , DESCRIPTION , OLD Price , New Price ,Is Approval Visible


								-------------End---------------------

							END
						ELSE
							BEGIN
								insert into [Products].[RoomDayPrice] ([ItemID],[LocationID],[Day],[BasePrice],[BasePriceSingle],[Commission],
									[Discount],[AddPax],[AddChild],[AddChildSr],[CreatedBy],[CreateDate],IsActive,AuthorizedFlag)
								values (@ItemID,@LocationID,@Day,@BasePrice,@BasePriceSingle,@Commission,@Discount,@AddPax,@AddChild,@AddChildSr,
									@UserID,getDate(),1,0)

									SET @DayRatesID = SCOPE_IDENTITY();	

									--- Insert Approval WorkFlow
									--SET @ProcessTypeId=4;
									--SET @ToUserId=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId ORDER BY ApprovalLevel ASC)
									--EXEC [reservation].[spCreateUpdateAppravalForTransaction]@ProcessTypeId, @LocationID, @UserID, @DayRatesID, 0, NULL, NULL, @ToUserId, NULL

									--- Insert Approval WorkFlow End - @ProcessTypeId, @LocationID, @UserID, @CurrencID, Status, ModifiedOn, ModifiedBy, @ToUserId, Remark
							END
						Set @DayID = @DayID +1
					END		

				SET @Message = 'Product day wise rate saved successfully.';
				SET @IsSuccess = 1; --success

			END				
			SET @NotDesc = @Message +'for ItemID:'+ STR(@ItemID) + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LogLocationID, @Title, @NotDesc	
					

					



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
			--SET @Message =  'User Role Objects has been changed successfully.';	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) =@Message -- (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 18,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END