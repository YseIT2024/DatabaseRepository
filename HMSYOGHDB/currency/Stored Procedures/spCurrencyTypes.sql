-- =============================================
-- Author:		<Rakesh>
-- ALTER date: <20 August>
-- Description:	<To Display Current Cash Desk Total Denomination Type>
-- =============================================
CREATE PROCEDURE [currency].[spCurrencyTypes]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
         SELECT DenominationTypeID,DenominationType FROM currency.DenominationType
END










