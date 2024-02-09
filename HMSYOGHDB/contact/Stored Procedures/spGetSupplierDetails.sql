
CREATE Proc [contact].[spGetSupplierDetails] --1
(
	@LocationID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--SELECT ContactPersonID,ContactPersonName,cct.ContactTypeID,ContactType ,d.ContactID, ISNULL(d.TitleID,0) TitleID, ISNULL(t.Title,'') Title, d.FirstName, 
	--ISNULL(d.LastName,'') LastName,ISNULL(a.Street,'') Street, ISNULL(a.City,'') City, ISNULL(a.[State], '') [State], ISNULL(a.ZipCode,'') ZipCode, a.CountryID, 
	--ISNULL(a.Email,'') Email, ISNULL(a.PhoneNumber,'') PhoneNumber, ISNULL(d.DOB,'') DOB, ISNULL(d.MaritalStatusID,0) MaritalStatusID, 
 --   ISNULL(d.LanguageID,0) LanguageID, ISNULL(d.IDCardTypeID,0) IDCardTypeID, ISNULL(id.IDCardTypeName,'') IDCardTypeName,
	--ISNULL(d.IDCardNumber,'') IDCardNumber,ISNULL(adt.AddressTypeID,0) AddressTypeID, ISNULL(a.AddressID,0) AddressID,ISNULL(c.CountryName,'') Country
	--FROM [contact].[ContactType] cct
	--INNER JOIN 
	--contact.[Address] a ON cp.ContactID = a.ContactID AND a.IsDefault = 1
	--INNER JOIN 
	--contact.AddressType adt ON a.AddressTypeID = adt.AddressTypeID 
	--INNER JOIN 
	--general.Country c ON a.CountryID = c.CountryID
	--INNER JOIN 
	--contact.Details d ON cp.ContactID = d.ContactID	
  
		select SupplierID,SupplierNo,ContactPerson,Designation,CD.FirstName as SupplierName,CD.ContactID,AddressID,AddressTypeID,Street,City,State,ZipCode,Email,PhoneNumber,AD.CountryID,CountryName
		from  general.Supplier GS
		inner join  contact.Details CD on CD.ContactID=GS.ContactID
		inner join  contact.Address AD on AD.ContactID=CD.ContactID
		inner join  general.Country GC on GC.CountryID=AD.CountryID

END











