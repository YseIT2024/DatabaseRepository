
CREATE Proc [general].[spUpdateCasinoRateCurrency]
(	
	@CurrencyID int,
	@DrawerID int,
	@UserID int
)
AS
BEGIN
	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(200) = '';
	DECLARE @OldCurrencyID int;

	BEGIN TRY
		SELECT @OldCurrencyID = CasinoRateCurrencyID
		FROM general.[Location]
		WHERE LocationID = @LocationID

		UPDATE general.[Location]
		SET CasinoRateCurrencyID = @CurrencyID
		WHERE LocationID = @LocationID

		SET @IsSuccess = 1;
		SET @Message = 'The Casino Rate Currency has been updated successfully.';

		DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
		DECLARE @Title varchar(200) = 'The Casino Rate Currency has been changed from ' + (SELECT CurrencyCode FROM currency.Currency WHERE CurrencyID = @OldCurrencyID)
		+ ' to ' + (SELECT CurrencyCode FROM currency.Currency WHERE CurrencyID = @CurrencyID);							
		DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Changed by User ID: ' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
	END TRY
	BEGIN CATCH
		SET @IsSuccess = 0;
		SET @Message = ERROR_MESSAGE();
	END CATCH

	SELECT @Message [Message], @IsSuccess [IsSuccess]
END


