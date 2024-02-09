Create PROCEDURE [reservation].[spTransferDataTempTableToRoomPriceTable] 
	@PriceID int
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @ItemId INT;
	DECLARE @FromDate date;
	DECLARE @LocationID INT;
	DECLARE @PriceIdNew int=1
	DECLARE @PriceID_Up int=1


	DECLARE @id int;
	DECLARE myCursor CURSOR FOR select ID from [Products].[RoomPriceTempTable] where DayPriceID=@PriceID;
	OPEN myCursor;
	FETCH NEXT FROM myCursor INTO @id;
	WHILE @@FETCH_STATUS = 0
		BEGIN

			select	@FromDate = FromDate from [Products].[RoomPriceTempTable] where ID=@id;

			if not exists (Select [PriceId] from Products.RoomPrice 
											where [ItemID] =(select ItemID from [Products].[RoomPriceTempTable] where ID=@id) 
											and [LocationID] = (select LocationID from [Products].[RoomPriceTempTable] where ID=@id)
											and DATEDIFF (day,[Fromdate],@FromDate)=0)
				BEGIN

					if(exists(select [Day] from [Products].[RoomDayPrice] 
									where [ItemID] = (select ItemID from [Products].[RoomPriceTempTable] where ID=@id) 
									and [LocationID] = (select LocationID from [Products].[RoomPriceTempTable] where ID=@id)
									and IsActive=1
									and [Day] = DATENAME(WEEKDAY,  @FromDate))) 
						BEGIN
							Select @PriceIdNew =isnull(max([PriceId]),0) +1 from Products.RoomPrice where [ItemID] =(select ItemID from [Products].[RoomPriceTempTable] where ID=@id)

							-- Insert new records from table1 into table2
							INSERT INTO [Products].[RoomPrice] ([PriceId],[ItemID],[PriceTypeID],[LocationID],[FromDate],[CurrencyID],[BasePrice],[BasePriceSingle],[Commission],[Discount],
							[AddPax],[AddChild],[AddChildSr],[SalePrice],[SalePriceSingle],[Remarks],[IsWeekEnd],[IsOnDemand],[CreatedBy],[CreateDate])
							SELECT
							@PriceIdNew
							,[ItemID],[PriceTypeID],[LocationID],[FromDate],[CurrencyID],[BasePrice],[BasePriceSingle],[Commission],[Discount],
							[AddPax],[AddChild],[AddChildSr],[SalePrice],[SalePriceSingle],[Remarks],[IsWeekEnd],[IsOnDemand],[CreatedBy],GETDATE()
							FROM [Products].[RoomPriceTempTable] t1
							WHERE ID=@id

						END

				END
			ELSE
				BEGIN
					 
					 Set @PriceID_Up=( Select [PriceId] from Products.RoomPrice where [ItemID] =(select ItemID from [Products].[RoomPriceTempTable] where ID=@id)  and [LocationID] = (select LocationID from [Products].[RoomPriceTempTable] where ID=@id)  	
								and DATEDIFF (day,[Fromdate],@FromDate)=0)


						UPDATE t2
						SET 
						t2.BasePrice = t1.BasePrice,
						t2.BasePriceSingle =t1.BasePriceSingle,
						t2.Commission = t1.Commission,
						t2.Discount = t1.Discount,
						t2.AddPax = t1.AddPax,
						t2.AddChild =t1.AddChild,
						t2.AddChildSr=t1.AddChildSr,
						t2.SalePrice =t1.SalePrice,
						t2.SalePriceSingle =t1.SalePriceSingle,
						t2.Remarks = NULL,
						t2.IsWeekEnd =t1.IsWeekEnd,
						t2.IsOnDemand =t1.IsOnDemand,
						t2.CreatedBy = t1.CreatedBy,
						t2.CreateDate = GETDATE()
						FROM [Products].[RoomPrice] t2
						JOIN [Products].[RoomPriceTempTable] t1 ON t2.ItemID = t1.ItemID and t2.LocationID=t1.LocationID and t2.Fromdate=t1.Fromdate and t2.PriceID=t1.PriceID
						where t1.ID=@id

				END
				 
	FETCH NEXT FROM myCursor INTO @id;
	END
	CLOSE myCursor;
	DEALLOCATE myCursor;
     

END