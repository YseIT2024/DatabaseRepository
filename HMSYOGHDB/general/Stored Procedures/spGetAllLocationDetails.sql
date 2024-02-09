CREATE PROCEDURE [general].[spGetAllLocationDetails] 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT loc.[LocationID]
      ,loc.[LocationTypeID] 	  ,loctype.LocationType      ,loc.[ParentID]	  ,locpar.LocationName ParentLocation
	  ,loc.[LocationCode]      ,loc.[LocationName]      ,loc.[CountryID]	  ,countr.[CountryName]
      ,loc.[MainCurrencyID] CurrencyID	  ,cur.CurrencyCode Currency
      --,loc.[LocalCurrencyID]      --,loc.[RateCurrencyID]
      ,loc.[ReportAddress]	
	  ,IIF(loc.[CheckInTime]='00:00:00',NULL,loc.[CheckInTime]) AS [CheckInTime]
	  ,IIF(loc.[CheckOutTime]='00:00:00',NULL,loc.[CheckOutTime]) AS [CheckOutTime]
	 --loc.[CheckInTime]	  ,
	 -- loc.[CheckOutTime] 
	 ,loc.commonreportlogo as [ReportLogo]
      ,loc.[HotelCashFigureHasToBeZero]      ,loc.[AllowNegativeStock]      ,loc.[IsActive]	  ,loc.[Remarks]
  FROM  [general].[Location] loc
  Inner join  [general].[LocationType] loctype On loc.LocationTypeID = loctype.LocationTypeID
  Inner join  [general].[Country] countr On loc.CountryID = countr.CountryID
  Inner join  [currency].[Currency] cur on loc.MainCurrencyID = cur.CurrencyID
  left join  [general].[Location] locpar on loc.ParentID =locpar.LocationID 
  ORDER BY loc.LocationID 
END


