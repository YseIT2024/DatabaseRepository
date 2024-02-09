
CREATE FUNCTION [account].[fnGetMainCurrencyValue]
(
	@dtAdvancePaymentSummary as [account].[dtAdvancePaymentBreakup] readonly
)
RETURNS decimal(18,4)
AS
BEGIN
	-- declare @MainCurrnecyValue decimal(18,4) =(select sum(case when CurrencyID=2 then Amount/Rate else Amount*Rate end) from @dtAdvancePaymentSummary)
	 declare @MainCurrnecyValue decimal(18,4) =(select sum(Amount/Rate) from @dtAdvancePaymentSummary)

	 
	 declare @incr int=1
	 declare @rowcount int=(select  count(*) from @dtAdvancePaymentSummary)



	 return @MainCurrnecyValue
END

