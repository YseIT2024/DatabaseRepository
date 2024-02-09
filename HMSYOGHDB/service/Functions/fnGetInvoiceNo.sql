
CREATE FUNCTION [service].[fnGetInvoiceNo](@LocationID int)
RETURNS INT
AS
BEGIN	
	DECLARE @InvoiceNo int = 
	(
		SELECT MAX(s.InvoiceNo)
		FROM reservation.[Service] s
		INNER JOIN guest.GuestWallet g ON s.ServiceID = g.ServiceID
		INNER JOIN reservation.Reservation r ON g.ReservationID = r.ReservationID
		WHERE r.LocationID = @LocationID
	);

	IF(@InvoiceNo IS NULL)
		BEGIN
			SET @InvoiceNo = CAST(CAST(@LocationID as varchar(3)) + CAST(100000 as varchar(10)) as int); 
		END
	ELSE
		BEGIN
			SET @InvoiceNo += 1;
		END

	RETURN @InvoiceNo;
END

