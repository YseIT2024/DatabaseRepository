CREATE proc [guest].[spDeleteCorporateAgrementHistory] --0,383
  --@RateContractsTable dbo.RateContractsTableType READONLY,
@IsActive bit,
@RateContractID int

as
begin

update [company].[RateContracts] set IsActive=@IsActive
where RateContractID=@RateContractID 

   SELECT A.RateContractID,
            A.CompanyID ,
            B.CompanyName, 
            SC.Name AS RoomType,
            IT.ItemName,
            A.ContractFrom,
            A.ContractTo,
			A.IsActive
        FROM [company].[RateContracts] A
        INNER JOIN [guest].[GuestCompany] B ON A.CompanyID = B.[CompanyID]
        INNER JOIN [Products].[Item] IT ON A.ItemID = IT.ItemID
        INNER JOIN [Products].[SubCategory] SC ON SC.SubCategoryID = IT.SubCategoryID 
        WHERE  ContractFrom> dateadd(YEAR,-1,getdate()) and a.IsActive=1 order by 1 desc

end


--update [company].[RateContracts] set IsActive=0
--where RateContractID=382