
CREATE PROCEDURE [service].[spServiceDetails] --'2020-05-14', '2020-09-14',1
(
	@FromDate date,
	@ToDate date,
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	SELECT s.InvoiceNo
	,FORMAT(s.[DateTime],'dd-MMM-yyyy') [Date]
	,rd.FolioNumber
	,rd.FullName [GuestName]
	,i.[Name] [ItemName]
	,sd.Quantity
	,p.Rate
	,p.Rate * sd.Quantity [Total]
	,CASE WHEN sp.ServiceID IS NULL THEN 'No' ELSE 'Yes' END [Paid]
	FROM reservation.[Service] s
	INNER JOIN reservation.vwReservationDetails rd ON s.ReservationID = rd.ReservationID
	INNER JOIN reservation.ServiceDetails sd ON s.ServiceID = sd.ServiceID
	INNER JOIN [service].Item i ON sd.ItemID = i.ItemID
	INNER JOIN [service].ItemRate ir ON sd.ItemRateID = ir.ItemRateID
	INNER JOIN currency.Price p ON ir.PriceID = p.PriceID
	LEFT JOIN reservation.ServicePayment sp ON s.ServiceID = sp.ServiceID
	WHERE rd.LocationID = @LocationID AND CAST(s.[DateTime] as date) BETWEEN @FromDate AND @ToDate
END

