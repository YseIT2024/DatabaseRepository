-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [Products].[GetPriceTypeDetails] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT [PriceTypeID]
      ,[Name]
      ,[Remarks]
      ,[Discount]
      ,[BasePriceType]
    FROM  [Products].[PriceType]

END



