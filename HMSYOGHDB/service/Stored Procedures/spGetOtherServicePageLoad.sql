
CREATE PROCEDURE [service].[spGetOtherServicePageLoad]
(
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ServiceTypeID, ServiceName
	FROM [service].[Type]
	WHERE ServiceTypeID <> 1 AND ShowInUI = 1

	SELECT CurrencyID, CurrencyCode
	FROM currency.Currency
END

