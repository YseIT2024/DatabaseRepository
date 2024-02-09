CREATE PROCEDURE [company].[sp_GetCompanyContractsRates]
AS
BEGIN
    SELECT   RC.RateContractID,RC.ItemId,GC.CompanyName, SC.Name,IM.ItemName, RC.ContractFrom,RC.ContractTo
    FROM [company].[RateContracts]  RC INNER JOIN
	[guest].[GuestCompany] GC ON RC.CompanyID=GC.CompanyID
	INNER JOIN [Products].[Item]  IM ON RC.ItemId=IM.ItemID
	INNER JOIN Products.SubCategory SC ON IM.SubCategoryID=SC.SubCategoryID
	--Where RC.IsActive=1 Order by RC.RateContractID desc
END