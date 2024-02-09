
CREATE PROCEDURE [service].[spGetFoodAndBeverage]
(
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);

	SELECT i.ItemID
	,r.ItemRateID
	,i.[Name]
	,i.ItemNumber
	,ISNULL(i.[Description],'') [Description]
	,ISNULL(i.Note,'') Note
	,t.ServiceName
	,ISNULL(f.FoodType,'') FoodType
	,p.Rate
	,p.CurrencyID
	,t.ServiceTypeID
	,ISNULL(f.FoodTypeID,'') FoodTypeID
	,r.PriceID
	,i.IsAvailable
	,CASE WHEN i.IsAvailable = 1 THEN 'Yes' ELSE 'No' END [Available]
	FROM [service].[Item] i
	INNER JOIN [service].[Type] t ON i.ServiceTypeID = t.ServiceTypeID	
	INNER JOIN [service].[ItemRate] r ON i.ItemID = r.ItemID
	INNER JOIN currency.Price p ON r.PriceID = p.PriceID
	LEFT JOIN [general].[FoodType] f ON i.FoodTypeID = f.FoodTypeID
	WHERE i.LocationID = @LocationID AND r.IsActive = 1 AND i.ServiceTypeID = 1
	ORDER BY i.ItemNumber
END

