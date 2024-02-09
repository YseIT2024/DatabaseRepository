
CREATE PROCEDURE [service].[spGetServiceForPayment] ---1144,1
(
	@ReservationID int,
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT s.ServiceID
	,s.InvoiceNo
	,st.ServiceName [ServiceType]
	,CAST(1 as bit) [Select]
	,COUNT(sd.ServiceID) [ItemCount]
	,SUM(p.Rate * sd.Quantity) [Amount]
	,FORMAT(s.[DateTime], 'dd-MMM-yyyy') [Date]
	FROM reservation.[Service] s
	INNER JOIN [service].[Type] st ON s.ServiceTypeID = st.ServiceTypeID
	INNER JOIN reservation.ServiceDetails sd ON s.ServiceID = sd.ServiceID
	INNER JOIN [service].ItemRate ir ON sd.ItemRateID = ir.ItemRateID
	INNER JOIN currency.Price p ON ir.PriceID = p.PriceID	
	INNER JOIN guest.GuestWallet gw ON s.ServiceID = gw.ServiceID
	LEFT JOIN [reservation].[ServicePayment] sp ON s.ServiceID = sp.ServiceID
	WHERE gw.ReservationID = @ReservationID AND sp.ServiceID IS NULL
	GROUP BY s.ServiceID, s.InvoiceNo, st.ServiceName, s.[DateTime], gw.Amount
END

