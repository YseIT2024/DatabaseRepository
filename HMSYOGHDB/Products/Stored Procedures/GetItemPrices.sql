
CREATE PROCEDURE [Products].[GetItemPrices] --'2023-12-23','2024-01-11'
    @FromDate DATETIME=NULL,
    @ToDate DATETIME=NULL,
	@ItemId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RP.PriceID, RP.ItemID, IM.ItemName, RP.LocationID, RP.FromDate, RP.CurrencyID, CC.CurrencyCode, RP.BasePrice, 
            RP.AddPax, RP.AddChild, RP.SalePrice, 
           RP.IsWeekEnd, RP.CreatedBy, 
           RP.CreateDate, RP.AddChildSr, 
           CASE 
              WHEN RP.IsApproved = 0 THEN 'Pending'
              WHEN RP.IsApproved = 1 THEN 'Approved'
              WHEN RP.IsApproved = 2 THEN 'Rejected'
            END AS ApprovalStatus,
           RP.ApprovedBy, RP.ApprovedOn
    FROM [Products].[RoomPriceNew] RP 
    INNER JOIN currency.Currency CC ON RP.CurrencyID = CC.CurrencyID
    INNER JOIN Products.Item IM ON RP.ItemID = IM.ItemID
    WHERE RP.ItemID=@ItemId AND RP.FromDate BETWEEN @FromDate AND @ToDate
END