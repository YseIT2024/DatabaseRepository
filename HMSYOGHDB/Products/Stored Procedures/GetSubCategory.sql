
CREATE PROCEDURE  [Products].[GetSubCategory] --1 
  @CategoryId int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT SC.CategoryID ,PC.Name as Category,SubCategoryID,SC.Name ,SC.Code,SC.Description,SC.Remarks,
	SC.CreatedBy as UserID ,CD.FirstName +' '+LastName as CreatedBy,SC.CreateDate,ISNULL(SC.AcceptOnlineReservations,0)as AcceptOnlineReservations,
	ISNULL(SC.IsActive,0) as IsActive--Added By Rajendra
	from Products.SubCategory  SC inner join app.[User] AU on SC.CreatedBy = AU.UserID
	Inner Join contact.Details CD on CD.ContactID= AU.ContactID
	Inner Join Products.Category PC on SC.CategoryID = PC.CategoryID 
	where SC.CategoryID = @CategoryId AND SC.IsActive=1

END