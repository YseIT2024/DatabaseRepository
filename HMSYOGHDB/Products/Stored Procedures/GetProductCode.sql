

CREATE Proc [Products].[GetProductCode]
(
@SubCategoryID int=0
)
AS
BEGIN
		--Declare @SubCategoryID int=1

		select SUB.Code+CONVERT(varchar(50),count(ItemID)+1) as ProductCode
		from  Products.SubCategory SUB
		left join  Products.Item PIT on PIT.SubCategoryID=SUB.SubCategoryID
		where SUB.SubCategoryID=@SubCategoryID
		group by Code
		
					   			 			
END

