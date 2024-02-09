CREATE PROCEDURE [Products].[sp_GetAllItemPrices]  
AS
BEGIN
    SET NOCOUNT ON;
	Declare @IsActive bit=0;
SELECT  RP.PriceID, RP.ItemID, GC.CompanyName,IM.ItemName, RP.LocationID, RP.FromDate, RP.CurrencyID, CC.CurrencyCode, RP.BasePrice, 
        RP.AddPax, RP.AddChild, RP.SalePrice, 
        RP.IsWeekEnd, RP.CreatedBy,
        (SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM app.[User] au
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE au.UserID = RP.CreatedBy) AS RequestedBy,
        RP.CreateDate, RP.AddChildSr, 
        CASE 
            WHEN RP.IsApproved = 0 THEN 'Pending'
            WHEN RP.IsApproved = 1 THEN 'Approved'
            WHEN RP.IsApproved = 2 THEN 'Rejected'
        END AS ApprovalStatus,
        RP.IsApproved,
        RP.ApprovedBy, RP.ApprovedOn,@IsActive AS IsActive,
        CASE 
            WHEN GC.CompanyName IS NOT NULL AND GC.CompanyName <> '' THEN 1
            ELSE 0
        END AS IsCompanyContract,PS.Name AS RoomType
FROM [company].[RoomPriceNew] RP 
INNER JOIN company.RateContracts CR ON RP.ContractId=CR.RateContractID
INNER JOIN guest.GuestCompany GC ON CR.CompanyID=GC.CompanyID
INNER JOIN currency.Currency CC ON RP.CurrencyID = CC.CurrencyID
INNER JOIN Products.Item IM ON RP.ItemID = IM.ItemID
INNER JOIN Products.SubCategory PS On IM.SubCategoryID=PS.SubCategoryID

WHERE RP.IsApproved = 0

UNION

SELECT  RP.PriceID, RP.ItemID, NULL AS CompanyName, IM.ItemName, RP.LocationID, RP.FromDate, RP.CurrencyID, CC.CurrencyCode, RP.BasePrice, 
        RP.AddPax, RP.AddChild, RP.SalePrice, 
        RP.IsWeekEnd, RP.CreatedBy,
        (SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
         FROM app.[User] au
         INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
         INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
         WHERE au.UserID = RP.CreatedBy) AS RequestedBy,
        RP.CreateDate, RP.AddChildSr, 
        CASE 
            WHEN RP.IsApproved = 0 THEN 'Pending'
            WHEN RP.IsApproved = 1 THEN 'Approved'
            WHEN RP.IsApproved = 2 THEN 'Rejected'
        END AS ApprovalStatus,
        RP.IsApproved,
        RP.ApprovedBy, RP.ApprovedOn,@IsActive AS IsActive,
        0 AS IsCompanyContract,PS.Name AS RoomType
   FROM [Products].[RoomPriceNew] RP 
   INNER JOIN currency.Currency CC ON RP.CurrencyID = CC.CurrencyID
   INNER JOIN Products.Item IM ON RP.ItemID = IM.ItemID
   INNER JOIN Products.SubCategory PS On IM.SubCategoryID=PS.SubCategoryID

   WHERE RP.IsApproved = 0;

END