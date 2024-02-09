
  
  

CREATE Proc [Products].[GetComboItems] 
(
@CategoryID int
)
AS  
BEGIN  
   --Declare @CategoryID int=2
  
  select ItemID,ItemName,Price,PRS.Description as SubCategory
  from  Products.Item PRI
  inner join  Products.SubCategory PRS on PRS.SubCategoryID=PRI.SubCategoryID
  where ItemTypeID=1 and PRI.CategoryID=@CategoryID;
             
END  
  
  


