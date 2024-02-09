
CREATE PROCEDURE [dbo].[spInsertIntoNotification]
(
	@LocationID int,
	@Title varchar(200),
	@Description varchar(max)
)
AS
BEGIN
	BEGIN TRY
		INSERT INTO [dbo].[Notification]
		([LocationID],[Title],[Description],[DateTime])
		VALUES (@LocationID, @Title, @Description, GETDATE())
	END TRY
	BEGIN CATCH
		---------------------------- Insert INTO activity log---------------	
		DECLARE @Act varchar(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 5,@LocationID,@Act,1	
	END CATCH
END


