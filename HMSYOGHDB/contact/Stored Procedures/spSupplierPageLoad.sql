
CREATE Proc [contact].[spSupplierPageLoad]
AS
BEGIN	
	

	SELECT AddressTypeID, AddressType
	FROM  contact.AddressType

	SELECT CountryID, CountryName  
	FROM  general.Country
	WHERE IsActive = 1

	Declare @SupplierPrefix varchar(20);
	select @SupplierPrefix= isnull([value],'SUP') from  app.Parameter where ParameterID =2

	select  @SupplierPrefix+convert(varchar, isnull(max(SupplierID),0)+ 1001) as SupplierNo 
	from  general.Supplier 

		
END











