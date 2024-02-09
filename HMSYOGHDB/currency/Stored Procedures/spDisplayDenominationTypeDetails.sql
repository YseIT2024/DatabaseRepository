

CREATE  PROCEDURE [currency].[spDisplayDenominationTypeDetails]
(
	@DenominationValueTypeId int
)
	
AS
BEGIN
		SELECT       [currency].[DenominationType].DenominationTypeId, [currency].[DenominationType].DenominationType, 
                         [currency].[DenominationType].DenominationValueTypeId, [currency].[DenominationType].CurrencyId, 
						[currency].[Currency].CurrencyCode, 
                         [currency].[DenominationValueType].DenominationValueType, 
						 ([currency].[Currency].CurrencyCode + ' - ' +[currency].[DenominationValueType].DenominationValueType) As DenominationValueCode
FROM         [currency].[DenominationType]   
			INNER JOIN
		[currency].[Currency] ON [currency].[DenominationType].CurrencyId = [currency].[Currency].CurrencyId
			INNER JOIN
  [currency].[DenominationValueType]   ON [currency].[DenominationValueType].DenominationValueTypeId = [currency].[DenominationType].DenominationValueTypeId
	Where [currency].[DenominationType].DenominationValueTypeId =  @DenominationValueTypeId
END









