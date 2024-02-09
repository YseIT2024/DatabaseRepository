
CREATE PROCEDURE [service].[spGetItemByServiceType] --8,1,3
(
	@DrawerID int,
	@ServiceTypeID int,
	@ReservationCurrencyID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	SELECT DISTINCT i.ItemID
	,0 ItemRateID
	,i.[Name] + ' ('+ CAST(i.ItemNumber as varchar(10)) +')' [Name]	
	,ISNULL(f.FoodType,'') FoodType
	,0.00 [RateD]	
	FROM [service].[Item] i
	INNER JOIN [service].[Type] t ON i.ServiceTypeID = t.ServiceTypeID	
	INNER JOIN [service].[ItemRate] r ON i.ItemID = r.ItemID
	INNER JOIN currency.Price p ON r.PriceID = p.PriceID
	INNER JOIN currency.Currency c ON p.CurrencyID = c.CurrencyID
	LEFT JOIN [general].[FoodType] f ON i.FoodTypeID = f.FoodTypeID
	WHERE i.LocationID = @LocationID AND i.ServiceTypeID = @ServiceTypeID AND r.IsActive = 1 AND i.IsAvailable = 1

	SELECT DISTINCT i.ItemID
	,r.ItemRateID	
	,p.Rate [RateD]
	,c.CurrencySymbol + CAST(CAST(p.Rate as decimal(18,2)) as varchar(7)) [Rate]
	FROM [service].[Item] i	
	INNER JOIN [service].[ItemRate] r ON i.ItemID = r.ItemID
	INNER JOIN currency.Price p ON r.PriceID = p.PriceID
	INNER JOIN currency.Currency c ON p.CurrencyID = c.CurrencyID	
	WHERE i.LocationID = @LocationID AND i.ServiceTypeID = @ServiceTypeID AND r.IsActive = 1 AND i.IsAvailable = 1 AND p.CurrencyID = @ReservationCurrencyID
	ORDER BY r.ItemRateID DESC
END
