-- =============================================
-- Author:		<Author,,Laxman Rao>
-- ALTER date: <ALTER Date,23-11-2019,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [account].[VerifyAccountingDateOpenOrClose]-- 1
(
  @DrawerID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	DECLARE @ReturnValue BIT 
	DECLARE @AccountingDate VARCHAR(11) = FORMAT(GETDATE(),'dd-MMM-yyyy')
	DECLARE @AccountingDateID INT = (SELECT MAX(AccountingDateId)+1 FROM account.AccountingDates)
	DECLARE @Drawer VARCHAR(20) = (SELECT Drawer FROM app.[Drawer] WHERE DrawerID = @DrawerID)
	DECLARE @Balance DECIMAL(18,2) =(SELECT account.[fnGetCashFigureBalance](@DrawerID))

	IF EXISTS(SELECT  AccountingDateId FROM account.AccountingDates  WHERE (DrawerID = @DrawerID) AND (IsActive = 1))
		BEGIN
			SELECT @AccountingDate = FORMAT(AccountingDate,'dd-MMM-yyyy') FROM account.AccountingDates  WHERE (DrawerID = @DrawerID) AND (IsActive = 1)
			SELECT @AccountingDateID = AccountingDateId FROM account.AccountingDates  WHERE (DrawerID = @DrawerID) AND (IsActive = 1)
			Set @ReturnValue  = 1
		END
	ELSE
		BEGIN
			Set @ReturnValue  = 0
		END	
		
		Select @ReturnValue As ReturnValue,  @AccountingDateID As AccountingDateID, @AccountingDate As AccountingDate, 
		@Drawer As Drawer , @Balance Balance
END

