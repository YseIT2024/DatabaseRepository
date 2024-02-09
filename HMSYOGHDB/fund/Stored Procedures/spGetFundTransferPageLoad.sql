-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spGetFundTransferPageLoad] --1
(
	@DrawerID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AccountingDateID INT;

	SELECT [FundFlowDirectionID], [FundFlowDirection] FROM [fund].[FundFlowDirection]

	SELECT  [FundTypeID], [FundType] FROM [fund].[Type]

	Set @AccountingDateID =  (SELECT AccountingDateId FROM account.AccountingDates 
	WHERE DrawerID = @DrawerID AND IsActive = 1 );

    SELECT AccountingDate FROM account.AccountingDates WHERE AccountingDateId = @AccountingDateID	


END


