create Procedure [Products].[spAutomateRoomPriceInsert]
AS
Begin 
		Declare
		@TodayDate DateTime = getDate(),
		@FromDate DateTime = Null,
		@ToDate DateTime = Null,
		@Count int = 1,
		@ItemID int = 1,
		@TotalItems int = 0
		DECLARE @CurrentDate DATE = GETDATE();
		DECLARE @EndDate DATE = DATEADD(DAY, 90, @CurrentDate);

		SELECT ROW_NUMBER() OVER (ORDER BY ItemID) AS RowNum, * into [Products].[#ItemstempTable] FROM [Products].[Item] WHERE IsActive=1 AND CategoryID=1 --and ItemID=1264

		Set @TotalItems = (SELECT Count(1) FROM [Products].[#ItemstempTable])

While(@Count <= @TotalItems)
	Begin

	 Set  @ItemID =  (Select ItemId From [Products].[#ItemstempTable] Where RowNum= @Count);
		-- CTE for calculating @FromDate
		 WITH DateCTE AS (
			SELECT @CurrentDate AS DateValue
			UNION ALL
			SELECT DATEADD(DAY, 1, DateValue)
			FROM DateCTE
			WHERE DateValue < @EndDate
		)
		 --Calculate @FromDate 
		Select  @FromDate = (
			SELECT Min(DateValue) 
			FROM DateCTE 
			WHERE DateValue NOT IN (
				Select FromDate 
				From [Products].[RoomPrice] 
				Where ItemID = @ItemID 
					And FromDate BETWEEN @CurrentDate AND @EndDate
			)
		);
		 
		-- CTE for calculating @ToDate
		WITH DateCTE AS (
			SELECT @CurrentDate AS DateValue
			UNION ALL
			SELECT DATEADD(DAY, 1, DateValue)
			FROM DateCTE
			WHERE DateValue < @EndDate
		)
		-- Calculate @ToDate
		Select  @ToDate = (
			SELECT Max(DateValue)
			FROM DateCTE 
			WHERE DateValue NOT IN (
				Select FromDate 
				From [Products].[RoomPrice] 
				Where ItemID = @ItemId 
					And FromDate BETWEEN @CurrentDate AND @EndDate
			)
		);
		
		-- Execute the room rates transaction
		Execute [room].[spRoomRatesTrans]  0, @ItemId, 1, @FromDate, @ToDate, 75, 1;
		
		Print @FromDate;
		Print @ToDate;
		Print @ItemId;
		Set @Count = @Count + 1;
		End
End