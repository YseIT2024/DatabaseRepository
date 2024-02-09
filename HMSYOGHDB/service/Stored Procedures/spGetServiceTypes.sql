
CREATE PROCEDURE [service].[spGetServiceTypes]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT ServiceTypeID, ServiceName
	FROM [service].[Type]
	WHERE ShowInUI = 1
END

