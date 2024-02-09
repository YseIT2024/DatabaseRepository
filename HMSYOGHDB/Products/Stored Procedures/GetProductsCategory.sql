CREATE Proc [Products].[GetProductsCategory]
AS
BEGIN
			
			select CategoryID,Name from  Products.Category where CategoryID = 1 --Room
			
END

