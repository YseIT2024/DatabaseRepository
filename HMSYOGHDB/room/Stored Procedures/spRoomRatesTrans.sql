
Create PROCEDURE [room].[spRoomRatesTrans]  --0,26,1,'12/2/2022','12/3/2022',75,1
(
	@PriceId		 int,
	@ItemID          int,
	@LocationID		 int,	
	@FromDate        date,
	@ToDate			 date,
	@UserID			 int,
	@LogLocationID	 int
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
	DECLARE @Itr int = 1;
	DECLARE @Count int;
	DECLARE @Day varchar(10)
	DECLARE @PriceIdNew int=1
	DECLARE @StartDate date
	DECLARE @Itritem int=1
	DECLARE @tempDates table (ID int identity(1,1),startdate date)
	DECLARE @TempItem table(ID int identity(1,1),ItemId int, Price Decimal(18,4))

	DECLARE @BasePrice       int
	DECLARE @BasePriceSingle int
	DECLARE @Commission		 int
	DECLARE @Discount		 int
	DECLARE @AddPax			 int
	DECLARE @AddChild		 int
	DECLARE @AddChildSr      int
	DECLARE @IsOnDemand      bit = 0
	DECLARE @DayPriceID int

	;WITH cte (startdate)
	AS 
	(SELECT
		@FromDate AS startdate
	UNION ALL
	SELECT
	DATEADD(DAY, 1, startdate) AS startdate
	FROM cte
	WHERE startdate < @ToDate
	)
	insert into @tempDates select c.startdate from cte c
	select @Count=count(*) from @tempDates	

	BEGIN TRY	
	
		BEGIN TRANSACTION	
			 
			while(@Itritem <=@Count)
			Begin
			  Select @StartDate=startdate from @tempDates where ID=@Itr 
			  
				if not exists (Select [PriceId] from Products.RoomPrice where [ItemID] =@ItemID and [LocationID] = @LocationID 
								--and IsActive=1 --Added by Arabinda on 21-07-2023
								and DATEDIFF (day,[Fromdate],@StartDate)=0)
					BEGIN
						if(exists(select [Day] from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID
									and IsActive=1  --Added by Arabinda on 21-07-2023 to filter only active rate
									and [Day] = DATENAME(WEEKDAY, @StartDate))) 
							BEGIN


								Select @PriceIdNew =isnull(max([PriceId]),0) +1 from Products.RoomPrice where [ItemID] =@ItemID
								select @BasePrice =[BasePrice],@BasePriceSingle =[BasePriceSingle],@Commission = [Commission],@Discount= [Discount],
										@AddPax = [AddPax], @AddChild=[AddChild],@AddChildSr=[AddChildSr] from [Products].[RoomDayPrice] 
										where [ItemID] =@ItemID and [LocationID] = @LocationID and [Day] = DATENAME(WEEKDAY, @StartDate) 
			
				
								if(exists(select [Day] from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and IsActive=1 and [Day] = DATENAME(WEEKDAY, @StartDate) AND AuthorizedFlag=1 AND IsRateChanged=1)) 
									BEGIN
									set @DayPriceID =(select PriceID from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and IsActive=1 and [Day] = DATENAME(WEEKDAY, @StartDate) AND AuthorizedFlag=1 AND IsRateChanged=1)
											INSERT INTO [Products].[RoomPriceTempTable]
											([PriceId],[ItemID],[PriceTypeID],[LocationID],[FromDate],[CurrencyID],[BasePrice],[BasePriceSingle],[Commission],[Discount],
											[AddPax],[AddChild],[AddChildSr],[SalePrice],[SalePriceSingle],[Remarks],[IsWeekEnd],[IsOnDemand],[CreatedBy],[CreateDate],[DayPriceID] )
								
											Select @PriceIdNew,@ItemID,1,@LocationID,@StartDate,1,@BasePrice,@BasePriceSingle,@Commission,@Discount,@AddPax,@AddChild,@AddChildSr,								
											(@BasePrice + ((@BasePrice * @Commission)/100))-(((@BasePrice + ((@BasePrice * @Commission)/100))*@Discount)/100),
											(@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))-(((@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))*@Discount)/100),								
											NULL,case DATENAME(WEEKDAY, @StartDate) when 'Saturday' then 1 when 'Sunday' then 1 else 0 end,
											@IsOnDemand,@UserID,getdate(),@DayPriceID

											if (exists(select IsApprovalVisible from reservation.ApprovalLog where ProcessTypeId=4 and RefrenceNo=@DayPriceID and IsApprovalVisible=0))
											BEGIN
												update reservation.ApprovalLog set IsApprovalVisible=1 where ProcessTypeId=4 and RefrenceNo=@DayPriceID
											END
											 
									END
								ELSE
									BEGIN
											INSERT INTO [Products].[RoomPrice]
											([PriceId],[ItemID],[PriceTypeID],[LocationID],[FromDate],[CurrencyID],[BasePrice],[BasePriceSingle],[Commission],[Discount],
											[AddPax],[AddChild],[AddChildSr],[SalePrice],[SalePriceSingle],[Remarks],[IsWeekEnd],[IsOnDemand],[CreatedBy],[CreateDate] )
								
											Select @PriceIdNew,@ItemID,1,@LocationID,@StartDate,1,@BasePrice,@BasePriceSingle,@Commission,@Discount,@AddPax,@AddChild,@AddChildSr,								
											(@BasePrice + ((@BasePrice * @Commission)/100))-(((@BasePrice + ((@BasePrice * @Commission)/100))*@Discount)/100),
											(@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))-(((@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))*@Discount)/100),								
											NULL,case DATENAME(WEEKDAY, @StartDate) when 'Saturday' then 1 when 'Sunday' then 1 else 0 end,
											@IsOnDemand,@UserID,getdate()
									END

								SET @Message = 'Product Rate created successfully.';
								SET @IsSuccess = 1; --success
							END
					END
				Else    -----Added by Arabinda on 21-07-2023 to update the rate if exist ---------
					begin
						
						Set @PriceId=( Select [PriceId] from Products.RoomPrice where [ItemID] =@ItemID and [LocationID] = @LocationID 	
								and DATEDIFF (day,[Fromdate],@StartDate)=0)
						select @BasePrice =[BasePrice],@BasePriceSingle =[BasePriceSingle],@Commission = [Commission],@Discount= [Discount],
										@AddPax = [AddPax], @AddChild=[AddChild],@AddChildSr=[AddChildSr] from [Products].[RoomDayPrice] 
										where [ItemID] =@ItemID and [LocationID] = @LocationID and [Day] = DATENAME(WEEKDAY, @StartDate) 
						

						if(exists(select [Day] from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and IsActive=1 and [Day] = DATENAME(WEEKDAY, @StartDate) AND AuthorizedFlag=1 AND IsRateChanged=1)) 
							BEGIN
								set @DayPriceID =(select PriceID from [Products].[RoomDayPrice] where [ItemID] = @ItemID and [LocationID] = @LocationID and IsActive=1 and [Day] = DATENAME(WEEKDAY, @StartDate) AND AuthorizedFlag=1 AND IsRateChanged=1)
									INSERT INTO [Products].[RoomPriceTempTable]
									([PriceId],[ItemID],[PriceTypeID],[LocationID],[FromDate],[CurrencyID],[BasePrice],[BasePriceSingle],[Commission],[Discount],
									[AddPax],[AddChild],[AddChildSr],[SalePrice],[SalePriceSingle],[Remarks],[IsWeekEnd],[IsOnDemand],[CreatedBy],[CreateDate],[DayPriceID] )
								
									Select @PriceId,@ItemID,1,@LocationID,@StartDate,1,@BasePrice,@BasePriceSingle,@Commission,@Discount,@AddPax,@AddChild,@AddChildSr,								
									(@BasePrice + ((@BasePrice * @Commission)/100))-(((@BasePrice + ((@BasePrice * @Commission)/100))*@Discount)/100),
									(@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))-(((@BasePriceSingle + ((@BasePriceSingle * @Commission)/100))*@Discount)/100),								
									NULL,case DATENAME(WEEKDAY, @StartDate) when 'Saturday' then 1 when 'Sunday' then 1 else 0 end,
									@IsOnDemand,@UserID,getdate(),@DayPriceID

									if (exists(select IsApprovalVisible from reservation.ApprovalLog where ProcessTypeId=4 and RefrenceNo=@DayPriceID and IsApprovalVisible=0))
									begin
									update reservation.ApprovalLog set IsApprovalVisible=1 where ProcessTypeId=4 and RefrenceNo=@DayPriceID
									end
							END
						ELSE
							BEGIN
							UPDATE Products.RoomPrice
							SET		
								BasePrice = @BasePrice,
								BasePriceSingle = @BasePriceSingle,
								Commission = @Commission,
								Discount = @Discount,
								AddPax = @AddPax,
								AddChild = @AddChild,
								AddChildSr=@AddChildSr,
								SalePrice = (@BasePrice + ((@BasePrice * @Commission) / 100)) - (((@BasePrice + ((@BasePrice * @Commission) / 100))) * @Discount) / 100,
								SalePriceSingle = (@BasePriceSingle + ((@BasePriceSingle * @Commission) / 100)) - (((@BasePriceSingle + ((@BasePriceSingle * @Commission) / 100))) * @Discount) / 100,
								Remarks = NULL,
								IsWeekEnd = CASE WHEN DATENAME(WEEKDAY, @StartDate) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END,
								IsOnDemand = @IsOnDemand,
								CreatedBy = @UserID,
								CreateDate = GETDATE()
								where PriceId=@PriceId and  itemid=@ItemID and  DATEDIFF (day,[Fromdate],@StartDate)=0

							END


						
								SET @Message = 'Product Rate modified successfully.';
								SET @IsSuccess = 1; --success

					end  -----End ---------
					
					
					set @Itritem =@Itritem +1;
					set @Itr =@Itr +1;				

			End
			
 
			
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
