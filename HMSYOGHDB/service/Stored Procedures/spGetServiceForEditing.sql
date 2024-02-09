
CREATE PROCEDURE [service].[spGetServiceForEditing]
(
    @ServiceID int 
)
AS
BEGIN
	SELECT DISTINCT [ServiceTypeID], [InvoiceNo], [CurrencyID]
	FROM [reservation].[Service] s
	WHERE s.ServiceID = @ServiceID

	SELECT DISTINCT [ItemID], [ItemRateID], [Quantity]
	FROM [reservation].[ServiceDetails] sd
	WHERE sd.ServiceID = @ServiceID
END

