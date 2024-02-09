CREATE PROCEDURE [app].[spGetLocationDefaultData] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT  [CurrencyID] ,[CurrencyCode]
  FROM  [currency].[Currency]

  SELECT [CountryID],[CountryName]
  FROM  [general].[Country] where IsActive = 1

  SELECT  [LocationTypeID] ,[LocationType]
  FROM  [general].[LocationType] where LocationTypeID <> 1 -- To avoide multiple Hotel Creation (Murugesh)--

  select [LocationID], [LocationName] as ParentLocation
   FROM  [general].[Location] where ISACTIVE=1 AND  LocationID=1   ---TO AVOID MULTIPLE LOCATIONS TO Load 1 Location
   --[ParentID] is null 

END


