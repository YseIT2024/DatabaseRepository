
CREATE PROCEDURE [service].[uspConciergeBookingPageLoad_Select] 
(
	@DrawerID int,
	@LocationID int,
	@TourismPackageID int = 0,
	@ServiceTypeID int =null
)
AS
BEGIN
	SET NOCOUNT ON;

	--Get Tourism Packages
	if @ServiceTypeID>0 
	begin
		SELECT ItemId, [Name] AS TourismPackage FROM [service].[Item] WHERE ServiceTypeID = @ServiceTypeID AND IsAvailable=1  and LocationID = @LocationID	
	end

	else
	begin
		SELECT ItemId, [Name] AS TourismPackage FROM [service].[Item] WHERE ServiceTypeID = 16 AND IsAvailable=1  and LocationID = @LocationID	
	end


	--Get Drivers
	select GE.EmployeeID, CD.ContactId, CD.Firstname + ' ' + CD.Lastname AS [Name] ,cd.DesignationID
	from [contact].[Details] CD 
	INNER JOIN [general].[Employee] GE ON CD.ContactID=GE.ContactID
	WHERE CD.DesignationID=16 -- Driver

	select GE.EmployeeID, CD.ContactId, CD.Firstname + ' ' + CD.Lastname AS [Name] ,cd.DesignationID
	from [contact].[Details] CD 
	INNER JOIN [general].[Employee] GE ON CD.ContactID=GE.ContactID
	WHERE CD.DesignationID=16
	

	SELECT CS.BookingID, CS.BookingCode, CS.ReservationID, RR.FolioNumber,RR.ActualCheckOut,RR.ExpectedCheckIn,CS.ServiceItemID,SI.[Name] as ServiceItem, CS.ServiceDate, CS.ServiceFromTime, CS.ServiceToTime, CS.AdultCount, CS.ChildCount, 
	CS.ServiceRate, CS.CarSegmentID, CS.CarSegmentCost,CI.[Name] as CarSegment,
	CS.DriverID,CD.Firstname  [DriverName], CS.DriverRate, 
	CS.GuideID,CD1.Firstname  AS [GuideName],CS.GuideRate,
	CS.Discount, CS.TotalAmountBeforeTax, CS.TaxPercent, CS.TotalTaxAmount, 
	CS.TotalAmountAfterTax, CS.AdditionalDiscount, CS.AdditionalDiscountAmount, CS.RoundoffAmt, CS.TotalPayableAmount, CS.TotalPaidAmount, CS.RefundAmount, 
	CS.Hold_TransactionModeID, CS.LocationID, CS.UserID, CS.[DateTime], CS.MainCurrencyID, CS.CurrencyID,
	SI.ItemNumber as Distance,
	CASE -----Added by Rajendra
		  WHEN CS.Mode =1 THEN 'CASH'  
		  WHEN CS.Mode =2 THEN 'CARD'		  
		  END AS CASHMODE,
		  CS.Mode,
		  CASE 
		  WHEN CS.CurrencyID =1 THEN 'USD'  
		  WHEN CS.CurrencyID =2 THEN 'SRD'
		  WHEN CS.CurrencyID =3 THEN 'EUR'	
		  END AS CurrencyCode,
		  CS.CurrencyRate,

	RR.ActualCheckIn, RR.ExpectedCheckOut, CT.FirstName as GuestName , (RR.Adults + RR.Children) PaxCount,
  (select [reservation].[fnGetReserveredRoom](RR.ReservationID)) as RoomNos

	FROM   service.ConciergService CS	
	INNER JOIN [reservation].[Reservation] RR on CS.ReservationID = RR.ReservationID

	LEFT join [guest].[Guest] GT on RR.GuestID = GT.GuestID
	LEFT  join [contact].[Details] CT on GT.ContactID = CT.ContactID

	LEFT  JOIN  [service].[Item] SI on CS.ServiceItemID = SI.ItemID
	LEFT  JOIN [service].[Item] CI on CS.CarSegmentID = CI.ItemID

	LEFT  JOIN [general].[Employee] EM on CS.DriverID = EM.EmployeeID
	LEFT  JOIN [contact].[Details] CD on EM.ContactID = CD.ContactID

	LEFT  JOIN [general].[Employee] EM1 on CS.GuideID = EM1.EmployeeID
	INNER JOIN [contact].[Details] CD1 on EM1.ContactID = CD1.ContactID
	ORDER BY CS.BookingID DESC

	--select CurrencyID,CurrencyCode from [currency].[Currency] --Commented By Rajendra

	SELECT c.CurrencyID, CONCAT (c.CurrencyCode,'-', er.NewRate) as CurrencyCode --Added By Rajendra
	,er.NewRate [CurrencyRateUSD]
	FROM [currency].[Currency] c
	INNER JOIN [currency].[ExchangeRateHistory] er ON c.CurrencyID = er.CurrencyID
	WHERE er.IsActive = 1 AND er.DrawerID = @DrawerID

	
	if(@TourismPackageID > 0)
	Begin		
	--Get car segment by packageID
		 select [ItemId], [Name] AS CarSegment from [service].[Item] where ItemID in 
		 (select CarServiceID from [service].[TourPackageCarMapping] where [TourPackageServiceID] = @TourismPackageID)
		 and IsAvailable = 1 and LocationID = @LocationID
		 order by [ItemId]

		 select [ItemID], [ItemRate], [Discount] from	[service].[ItemPrice] where ItemID = @TourismPackageID

		 select GT.TaxRate, GT.TaxID from [service].[ServiceTax] ST
		 inner join [general].[Tax] GT on ST.TaxID = GT.TaxID
		 where ST.ServiceTypeID = @TourismPackageID
		 
		 select ItemNumber as Distance from [service].[Item] where ItemID = @TourismPackageID
	End
	
END



	





