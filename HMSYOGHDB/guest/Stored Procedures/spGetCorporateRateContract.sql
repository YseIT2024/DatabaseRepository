
CREATE PROCEDURE [guest].[spGetCorporateRateContract]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
			SELECT IT.SubCategoryID  as RoomTypeID,
			SC.[Name] AS RoomType,
			IT.ItemID ItemID,
			IT.ItemName ItemName,
			IT.IsActive IsActive
                
				FROM [Products].[Item] IT
				INNER JOIN [Products].[SubCategory] SC ON SC.SubCategoryID = IT.SubCategoryID
				LEFT JOIN [guest].[GuestCompanyRateContract] GCR ON IT.ItemID = GCR.ItemID AND GCR.GuestCompanyID = 0 AND gcr.ContractTo>=getdate()
				LEFT JOIN [guest].[GuestCompany] GC ON GC.CompanyID = GCR.GuestCompanyID
				WHERE IT.IsActive=1 and SC.CategoryID=1 and SC.IsActive=1
				ORDER BY IT.SubCategoryID;

     
END
