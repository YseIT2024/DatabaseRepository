
CREATE  PROCEDURE [currency].[spDisplayDenominationValueTypes]	
AS
BEGIN
	SELECT DenominationValueTypeId, DenominationValueType
	FROM [currency].[DenominationValueType] WHERE ISACTIVE=1 
	ORDER BY DenominationValueTypeId DESC
END

