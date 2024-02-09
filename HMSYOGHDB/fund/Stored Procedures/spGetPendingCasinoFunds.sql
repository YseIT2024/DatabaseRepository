-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [fund].[spGetPendingCasinoFunds]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT FundFlowID, USDAmount, SRDAmount, EURAmount, SealbagNumber, AccountingDate 
	FROM [fund].[Flow] f
	INNER JOIN account.AccountingDates a ON f.AccountingDateID = a.AccountingDateId
	WHERE FundFlowDirectionID = 2 AND FundFlowStatusID = 2

END

