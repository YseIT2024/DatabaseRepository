CREATE Proc [Products].[GetCuisineTypes]  
AS  
BEGIN  
   
  select CuisineTypeID,Name as CuisineType from   Products.CuisineType  
  
                 
END  

