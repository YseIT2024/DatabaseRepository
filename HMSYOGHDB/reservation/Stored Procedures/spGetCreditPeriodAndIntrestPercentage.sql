CREATE PROCEDURE [reservation].[spGetCreditPeriodAndIntrestPercentage] --3,1
	(
	@CompanyId int,
	@LocationId int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	ISNULL(CreditPeriod,0) AS CreditPeriod
	,ISNULL(IntrestPercentageAfterCreditPeriod,0)  as IntrestPercentage
	,CONCAT(ISNULL(CreditPeriod,0) ,' days credit period and ',ISNULL(IntrestPercentageAfterCreditPeriod,0),'% of interest') AS Command
	FROM  guest.GuestCompany WHERE CompanyID=@CompanyID AND IsCredit=1

END
