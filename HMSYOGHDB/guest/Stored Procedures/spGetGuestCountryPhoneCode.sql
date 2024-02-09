
CREATE PROCEDURE [guest].[spGetGuestCountryPhoneCode]
@CountryId Int =null
AS
BEGIN	
	

	Select ITUTTelephoneCode from general.Country Where CountryID=@CountryId
		
END