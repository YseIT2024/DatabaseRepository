CREATE PROCEDURE guest.spCorporateHistory 
   
    @CompanyID int,
    @ItemID int,
	@ContractFrom datetime,
	@ContractTo datetime
AS
BEGIN
    BEGIN
        INSERT INTO [company].[RateContracts] (CompanyID, ItemID, ContractFrom, ContractTo) 
       values (  @CompanyID ,
    @ItemID ,
	@ContractFrom ,
	@ContractTo )
    END

    BEGIN
        SELECT 
            A.CompanyID as CompanyID,
            B.CompanyName, 
            SC.Name as RoomType,
            IT.ItemName,
            A.ContractFrom,
            A.ContractTo
        FROM [company].[RateContracts] A
        INNER JOIN [guest].[GuestCompany] B ON A.CompanyID = B.[CompanyID]
        INNER JOIN [Products].[Item] IT ON A.ItemID = IT.ItemID
        INNER JOIN [Products].[SubCategory] SC ON SC.SubCategoryID = IT.SubCategoryID 
        WHERE A.CompanyID = @CompanyID 
		--AND A.ItemId = @ItemID;
    END
END
