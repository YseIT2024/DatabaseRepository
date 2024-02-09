
-- =============================================
-- Author:          <ARABINDA PADHI>
-- Create date: <27/01/2023>
-- Description:     <TO GET THE RATE CONTRACT WITH GUEST COMPANY>
-- =============================================

CREATE PROCEDURE [guest].[spGetGuestRateContract] --0,2,0,75
(	
	@RateContractID int = 0,
	@GuestCompanyID int = 0,
    @ItemID int = 0,   
    @UserId varchar(50)  
   
)
AS
BEGIN
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;
		
	IF(@RateContractID <> 0)
		BEGIN
			SELECT A.RateContractID,A.GuestCompanyID,A.ItemID,A.ContractFrom,A.ContractTo
			--,A.NetRate,A.SellRate
			,CAST(A.NetRate AS DECIMAL(18, 2)) AS NetRate, CAST(A.SellRate AS DECIMAL(18, 2)) AS SellRate --Vivek - Rounding off to 2 decimals
				,A.DiscountPercent,A.DiscountAmt,A.IsActive,A.CreatedBy,A.CreatedOn,
				B.CompanyID,B.CompanyName,B.CompanyAddress,B.CompanyEmail,B.CompanyPhoneNumber,B.POCName,
				B.POCDisignation,B.ReservationTypeId
				FROM [guest].[GuestCompanyRateContract] A
				INNER JOIN [guest].[GuestCompany] B ON A.GuestCompanyID=B.CompanyID
				WHERE  A.RateContractID=@RateContractID;

		END
	ELSE IF (@GuestCompanyID <>0)
		BEGIN
			--SELECT A.RateContractID,A.GuestCompanyID, B.CompanyName, IT.SubCategoryID, SC.[Name],  A.ItemID, IT.ItemName,A.ContractFrom,A.ContractTo
			----,A.NetRate,A.SellRate
			--,CAST(A.NetRate AS DECIMAL(18, 2)) AS NetRate, CAST(A.SellRate AS DECIMAL(18, 2)) AS SellRate --Vivek - Rounding off to 2 decimals
			--	,A.DiscountPercent,A.DiscountAmt,A.IsActive,A.CreatedBy,A.CreatedOn,
			--	B.CompanyID,B.CompanyAddress,B.CompanyEmail,B.CompanyPhoneNumber,B.POCName,
			--	B.POCDisignation,B.ReservationTypeId
			--	FROM [guest].[GuestCompanyRateContract] A
			--	INNER JOIN [guest].[GuestCompany] B ON A.GuestCompanyID=B.CompanyID		
			--	INNER JOIN [Products].[Item] IT ON A.ItemID = IT.ItemID
			--	INNER JOIN [Products].[SubCategory] SC ON IT.SubCategoryID = SC.SubCategoryID
			--	WHERE A.GuestCompanyID=@GuestCompanyID
				--union
				--SELECT 0 as RateContractID,@GuestCompanyID as GuestCompanyID, 0 as CompanyName, 
				--IT.SubCategoryID, SC.[Name],  IT.ItemID, IT.ItemName, null as ContractFrom, getdate() as ContractTo
			 -- , 0 AS NetRate, 0 AS SellRate --Vivek - Rounding off to 2 decimals
				--, 0 as DiscountPercent,0 as DiscountAmt,0 as IsActive, 0 as CreatedBy,getdate() as CreatedOn,
				--@GuestCompanyID as CompanyID,0 AS CompanyAddress,0 AS CompanyEmail, 0 AS CompanyPhoneNumber,0 AS POCName,
				--0 AS POCDisignation,0 AS ReservationTypeId
			
				--FROM 	[Products].[SubCategory] SC				
				--INNER JOIN [Products].[Item] IT ON SC.SubCategoryID=IT.SubCategoryID AND IT.IsActive=1				
				--WHERE SC.CategoryID=1 AND SC.IsActive=1;

				SELECT GCR.RateContractID,GCR.GuestCompanyID,IT.SubCategoryID,SC.[Name] AS Name,IT.ItemID,IT.ItemName,GCR.ContractFrom
	            ,GCR.ContractTo,GCR.NetRate,GCR.SellRate,CAST(GCR.NetRate AS DECIMAL(18, 2)) AS NetRate
	            ,CAST(GCR.SellRate AS DECIMAL(18, 2)) AS SellRate --Vivek - Rounding off to 2 decimals
                ,GCR.DiscountPercent,GCR.DiscountAmt,GCR.IsActive,GCR.CreatedBy,GCR.CreatedOn,GC.CompanyID as CustomerID
	            ,GC.CompanyAddress,GC.CompanyEmail,GC.CompanyPhoneNumber,GC.POCName,GC.POCDisignation,GC.ReservationTypeId
				FROM [Products].[Item] IT
				INNER JOIN [Products].[SubCategory] SC ON SC.SubCategoryID = IT.SubCategoryID
				LEFT JOIN [guest].[GuestCompanyRateContract] GCR ON IT.ItemID = GCR.ItemID AND GCR.GuestCompanyID = @GuestCompanyID AND gcr.ContractTo>=getdate()
				LEFT JOIN [guest].[GuestCompany] GC ON GC.CompanyID = GCR.GuestCompanyID
				WHERE IT.IsActive=1 and SC.CategoryID=1 and SC.IsActive=1
				ORDER BY IT.SubCategoryID, IT.ItemCode;


		END
	ELSE IF (@ItemID <> 0)
		BEGIN
			SELECT A.RateContractID,A.GuestCompanyID,A.ItemID,A.ContractFrom,A.ContractTo
			--,A.NetRate,A.SellRate
			,CAST(A.NetRate AS DECIMAL(18, 2)) AS NetRate, CAST(A.SellRate AS DECIMAL(18, 2)) AS SellRate --Vivek - Rounding off to 2 decimals
				,A.DiscountPercent,A.DiscountAmt,A.IsActive,A.CreatedBy,A.CreatedOn,
				B.CompanyID,B.CompanyName,B.CompanyAddress,B.CompanyEmail,B.CompanyPhoneNumber,B.POCName,
				B.POCDisignation,B.ReservationTypeId
				FROM [guest].[GuestCompanyRateContract] A
				INNER JOIN [guest].[GuestCompany] B ON A.GuestCompanyID=B.CompanyID
			WHERE A.ItemID=@ItemID
		END
	ELSE
		BEGIN

			SELECT [CompanyID] as CustomerID,[CompanyName] as CustomerName FROM [guest].[GuestCompany] 

			SELECT A.GuestCompanyID as CustomerID, IT.ItemName,A.ContractFrom,A.ContractTo
			--,A.NetRate
			,CAST(A.NetRate AS DECIMAL(18, 2)) AS NetRate --Vivek - Rounding off to 2 decimals
			,A.DiscountPercent as Discount
			--,A.SellRate
			,CAST(A.SellRate AS DECIMAL(18, 2)) AS SellRate --Vivek - Rounding off to 2 decimals
			,A.IsActive				
				FROM [guest].[GuestCompanyRateContract] A
				INNER JOIN [guest].[GuestCompany] B ON A.GuestCompanyID=B.[CompanyID]		
				INNER JOIN [Products].[Item] IT ON A.ItemID = IT.ItemID
				--INNER JOIN [Products].[SubCategory] SC ON IT.SubCategoryID = SC.SubCategoryID

			--SELECT A.RateContractID,A.GuestComanyID,A.ItemID,A.ContractFrom,A.ContractTo,A.NetRate,A.SellRate
			--	,A.DiscountPercent,A.DiscountAmt,A.IsActive,A.CreatedBy,A.CreatedOn,
			--	B.GuestCompanyID,B.GuestCompanyName,B.GuestCompanyAddress,B.GuestCompanyEmail,B.GuestCompanyPhoneNumber,B.GuestCompanyContactName,
			--	B.GuestCompanyContactDisignation,B.ReservationTypeId
			--	FROM [guest].[GuestCompanyRateContract] A
			--	INNER JOIN [guest].[GuestCompany] B ON A.GuestComanyID=B.GuestCompanyID


		END

END