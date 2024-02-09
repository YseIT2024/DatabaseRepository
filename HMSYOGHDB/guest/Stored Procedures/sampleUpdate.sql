create proc [guest].[sampleUpdate] --'2023-04-07','2023-04-14',331
  --@RateContractsTable dbo.RateContractsTableType READONLY,
@ContractFrom datetime,
@ContractTo datetime,
@RateContractID int

as
begin

update  [company].[RateContracts] set ContractFrom=@ContractFrom , ContractTo=@ContractTo, ModifiedBy=@ContractFrom, ModifiedOn=@ContractTo 
where RateContractID=@RateContractID 

   SELECT a.RateContractID,
            A.CompanyID ,
            B.CompanyName, 
            SC.Name AS RoomType,
            IT.ItemName,
            A.ContractFrom,
            A.ContractTo
        FROM [company].[RateContracts] A
        INNER JOIN [guest].[GuestCompany] B ON A.CompanyID = B.[CompanyID]
        INNER JOIN [Products].[Item] IT ON A.ItemID = IT.ItemID
        INNER JOIN [Products].[SubCategory] SC ON SC.SubCategoryID = IT.SubCategoryID 
        WHERE  ContractFrom> dateadd(YEAR,-1,getdate()) and a.IsActive=1 order by 1 desc

end