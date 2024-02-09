
CREATE PROCEDURE [reservation].[getSplitBillValidation]
	@InvoiceNo int
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT COUNT(*) as IsValid from reservation.Invoice where ParentInvoiceNo=@InvoiceNo

END
