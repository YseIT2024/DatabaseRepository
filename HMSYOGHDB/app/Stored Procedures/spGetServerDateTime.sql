
CREATE PROCEDURE [app].[spGetServerDateTime]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT GETDATE() AS 'ServerDateTime'
END









