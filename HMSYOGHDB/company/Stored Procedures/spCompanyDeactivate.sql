-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [company].[spCompanyDeactivate] 
(
	@CompanyID int,
	@ContactID int,
	@IsActive bit,
	@UserID int,
	@DrawerID int
)
AS
BEGIN
	DECLARE @Success Bit = 0;
	DECLARE @Message varchar(100) = '';

	DECLARE @LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID)

	BEGIN TRY
		IF EXISTS(SELECT CompanyID FROM company.CompanyAndContactPerson WHERE CompanyID = @CompanyID AND ContactID = @ContactID)
		BEGIN
			UPDATE company.CompanyAndContactPerson SET
			IsActive = @IsActive
			WHERE CompanyID = @CompanyID AND ContactID = @ContactID
		END
		ELSE
		BEGIN
			IF(@ContactID = 0)
				UPDATE company.Company
				SET ContactID = 0
				WHERE CompanyID = @CompanyID

			INSERT INTO company.CompanyAndContactPerson
			(CompanyID, ContactID, IsActive)
			SELECT @CompanyID, @ContactID, @IsActive
		END

		SET @Success = 1;
		IF @IsActive = 0
			SET @Message = 'Company has been de-activated successfully.'	
		ELSE	
			SET @Message = 'Company has been activated successfully.'	

		DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
		DECLARE @Title varchar(200) = 'Company: ' + (SELECT CompanyName FROM company.Company WHERE CompanyID = @CompanyID) 
		+ ' has ' + CASE WHEN @IsActive = 0 THEN 'de-activated' ELSE 'activated' END
		DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
	END TRY
	BEGIN CATCH
		SET @Success = 0;
		SET @Message = ERROR_MESSAGE();

		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID
	END CATCH	

	SELECT @Success Success, @Message Message
END


