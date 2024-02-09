-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [room].[GetRoomRates] --1,1,'2022-11-01','2022-11-08'
	(
	 @LocationID int,
	 @ItemID int,
	 @FromDate date,
	 @ToDate date
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT rPrice.[PriceID]
      ,rPrice.[ItemID]
	  ,item.[ItemName]
	  ,item.[SubCategoryID] RoomTypeID
	  ,sCat.[Name] RoomType
      ,rPrice.[PriceTypeID]
	  ,pType.[Name] PriceType
      ,rPrice.[LocationID]
	  ,lc.[LocationName]
      ,rPrice.[FromDate]
      ,rPrice.[CurrencyID]
	  ,crncy.[CurrencyCode]
      ,rPrice.[BasePrice]
	  ,rPrice.[BasePriceSingle]
	  ,rPrice.[Commission]
	  ,rPrice.[Discount]
      ,rPrice.[SalePrice]
	  ,rPrice.[SalePriceSingle]
      ,rPrice.[Remarks]
      ,rPrice.[AddPax]
      ,rPrice.[AddChild]
	  ,rPrice.[AddChildSr]
      ,rPrice.[IsOnDemand]
      ,rPrice.[IsWeekEnd]
      ,rPrice.[Priority]
  FROM  [Products].[RoomPrice] rPrice  
  INNER JOIN  [Products].[Item] item ON rPrice.[ItemID] = item.[ItemID]
  INNER JOIN  [Products].[PriceType] pType ON rPrice.[PriceTypeID] = pType.[PriceTypeID]
  INNER JOIN  [general].[Location] lc ON rPrice.[LocationID] = lc.[LocationID]
  INNER JOIN  [currency].[Currency] crncy ON rPrice.[CurrencyID] = crncy.[CurrencyID]
  INNER JOIN  [Products].[SubCategory] sCat ON item.[SubCategoryID] = sCat.[SubCategoryID]
  WHERE rPrice.[LocationID] = @LocationID and rPrice.[ItemID] = @ItemID and (rPrice.[FromDate] between @FromDate and @ToDate)-- or [FromDate] = @FromDate or [FromDate] = @FromDate)

END