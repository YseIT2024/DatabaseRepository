-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [general].[spPopulateAreaLocations]
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT  ID,lp.LocationID,l.LocationCode,DBConnectionString,ApiBaseUri,DefaultCountryID
	FROM [general].[LocationParameter] lp
	INNER JOIN [general].[Location] l ON lp.LocationID=l.LocationID

END










