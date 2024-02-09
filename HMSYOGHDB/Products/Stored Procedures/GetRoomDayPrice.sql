-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [Products].[GetRoomDayPrice] --1,1
	(
	 @LocationID int,
	 @ItemID int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 

	DECLARE @tempDays table ([Day] varchar(10),[Seq] int)
    insert into @tempDays([Day],[Seq]) values ('Monday',1),('Tuesday',2),('Wednesday',3),('Thursday',4),('Friday',5),('Saturday',6),('Sunday',7)

	 SELECT 0 as [Select]
			,tDay.[Day]
			,rmdPrice.[PriceID]
			,rmdPrice.[ItemID]
			,rmdPrice.[LocationID]
			--,rmdPrice.[Day]
			,rmdPrice.[BasePrice]
			,rmdPrice.[BasePriceSingle]
			,rmdPrice.[Commission]
			,rmdPrice.[Discount]
			,rmdPrice.[AddPax]
			,rmdPrice.[AddChild],rmdPrice.[AddChildSr] FROM @tempDays tDay
			LEFT JOIN  [Products].[RoomDayPrice] rmdPrice ON tDay.[Day] = rmdPrice.[Day] and [ItemID] = @ItemID and [locationID] = @LocationID	and rmdPrice.IsActive=1 
			
			order by tDay.Seq
  
	--if not exists (Select [PriceId] from [Products].[RoomDayPrice] where [ItemID] =@ItemID and [LocationID] = @LocationID)								
	--	BEGIN
	--	 SELECT 0 as [Select]
	--		,tDay.[Day]
	--		,rmdPrice.[PriceID]
	--		,rmdPrice.[ItemID]
	--		,rmdPrice.[LocationID]
	--		--,rmdPrice.[Day]
	--		,rmdPrice.[BasePrice]
	--		,rmdPrice.[BasePriceSingle]
	--		,rmdPrice.[Commission]
	--		,rmdPrice.[Discount]
	--		,rmdPrice.[AddPax]
	--		,rmdPrice.[AddChild] FROM @tempDays tDay
	--		LEFT JOIN  [Products].[RoomDayPrice] rmdPrice ON tDay.[Day] = rmdPrice.[Day] and [ItemID] = @ItemID and [locationID] = @LocationID	
	--		order by tDay.Seq
	--	END
	--ELSE
	--	BEGIN
	--		SELECT 0 as [Select]
	--			,tDay.[Day]
	--			,rmdPrice.[PriceID]
	--			,rmdPrice.[ItemID]
	--			,rmdPrice.[LocationID]
	--			--,rmdPrice.[Day]
	--			,rmdPrice.[BasePrice]
	--			,rmdPrice.[BasePriceSingle]
	--			,rmdPrice.[Commission]
	--			,rmdPrice.[Discount]
	--			,rmdPrice.[AddPax]
	--			,rmdPrice.[AddChild] FROM @tempDays tDay
	--			LEFT JOIN  [Products].[RoomDayPrice] rmdPrice ON tDay.[Day] = rmdPrice.[Day] and [ItemID] = @ItemID and [locationID] = @LocationID	
	--		where rmdPrice.IsActive=1 
	--		order by tDay.Seq

	--	END
	
	

	
	

END