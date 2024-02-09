
CREATE PROCEDURE [guest].[spCorporateAgrementHistory] 
    @RateContractsTable dbo.RateContractsTableType READONLY,
    @SelectedCompanyID int,
    @SelectedItemID int
AS
BEGIN
    BEGIN 
        -- Insert data from @RateContractsTable into [company].[RateContracts]
   INSERT INTO [company].[RateContracts] (CompanyID, ItemID, ContractFrom, ContractTo,IsActive) 
    SELECT CompanyID, ItemID, ContractFrom, ContractTo,IsActive
 --from company.RateContracts
    FROM @RateContractsTable
    WHERE CompanyID != 0; 


        -- Fetch records based on @SelectedCompanyID and @SelectedItemID
        SELECT a.RateContractID,
            A.CompanyID,
            B.CompanyName, 
            SC.Name AS RoomType,
            IT.ItemName,
            A.ContractFrom,
            A.ContractTo
        FROM company.RateContracts A
        INNER JOIN guest.GuestCompany B ON A.CompanyID = B.CompanyID
        INNER JOIN Products.Item IT ON A.ItemID = IT.ItemID
        INNER JOIN Products.SubCategory SC ON SC.SubCategoryID = IT.SubCategoryID 
        WHERE  ContractFrom> dateadd(YEAR,-1,getdate()) and a.IsActive=1 order by 1 desc

    END 
END



