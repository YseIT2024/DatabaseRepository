
CREATE PROCEDURE [service].[spGetOtherServiceWithRate]
(
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	DECLARE @FoodNBeverageServiceTypeID int = 1;

	SELECT i.ItemID
	,i.[Name]
	,i.ItemNumber
	,ISNULL(i.[Description],'') [Description]
	,ISNULL(i.Note,'') Note
	,t.ServiceName
	,ISNULL(f.FoodType,'') FoodType
	,t.ServiceTypeID
	,ISNULL(f.FoodTypeID,'') FoodTypeID
	,i.IsAvailable
	,CASE WHEN i.IsAvailable = 1 THEN 'Yes' ELSE 'No' END [Available]
	FROM [service].[Item] i
	INNER JOIN [service].[Type] t ON i.ServiceTypeID = t.ServiceTypeID
	LEFT JOIN [general].[FoodType] f ON i.FoodTypeID = f.FoodTypeID
	WHERE i.LocationID = @LocationID AND t.ShowInUI = 1 AND i.ServiceTypeID <> @FoodNBeverageServiceTypeID
	ORDER BY i.ItemNumber

	SELECT i.ItemID
	,r.ItemRateID
	,FORMAT(r.ActivateDate,'dd-MMM-yyyy') [Date]
	,p.Rate [ActualRate]
	, c.CurrencySymbol + CAST(CAST(p.Rate as decimal(18,2)) as varchar(8)) [Rate]
	,p.CurrencyID
	,r.IsActive
	,CASE WHEN r.IsActive = 1 THEN 'Yes' ELSE 'No' END [Active]
	FROM [service].[Item] i
	INNER JOIN [service].[Type] t ON i.ServiceTypeID = t.ServiceTypeID
	INNER JOIN [service].[ItemRate] r ON i.ItemID = r.ItemID
	INNER JOIN currency.Price p ON r.PriceID = p.PriceID
	INNER join currency.Currency c ON p.CurrencyID = c.CurrencyID
	WHERE i.LocationID = @LocationID AND t.ShowInUI = 1 AND i.ServiceTypeID <> @FoodNBeverageServiceTypeID AND r.IsActive = 1
	ORDER BY i.ItemNumber
END
