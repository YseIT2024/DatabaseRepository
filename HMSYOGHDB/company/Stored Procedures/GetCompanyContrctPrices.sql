CREATE PROCEDURE [Company].[GetCompanyContrctPrices] --'2023-12-23','2024-01-11'
    @FromDate DATETIME=NULL,
    @ToDate DATETIME=NULL,
	@ContractId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RP.PriceID, RP.ItemID,RP.ContractId, IM.ItemName,GC.CompanyName, RP.LocationID, RP.FromDate, RP.CurrencyID, CC.CurrencyCode, RP.BasePrice, 
            RP.AddPax, RP.AddChild, RP.SalePrice, 
           RP.IsWeekEnd, RP.CreatedBy, 
           RP.CreateDate, RP.AddChildSr, 
           CASE 
              WHEN RP.IsApproved = 0 THEN 'Pending'
              WHEN RP.IsApproved = 1 THEN 'Approved'
              WHEN RP.IsApproved = 2 THEN 'Rejected'
            END AS ApprovalStatus,
           RP.ApprovedBy, RP.ApprovedOn
    FROM [company].[RoomPriceNew] RP 
	INNER JOIN company.RateContracts RC ON RP.ContractId=RC.RateContractID
	INNER JOIN guest.GuestCompany GC ON RC.CompanyID=GC.CompanyID
    INNER JOIN currency.Currency CC ON RP.CurrencyID = CC.CurrencyID
    INNER JOIN Products.Item IM ON RP.ItemID = IM.ItemID
    WHERE RP.ContractId=@ContractId AND RP.FromDate BETWEEN @FromDate AND @ToDate
END