CREATE PROC [Housekeeping].[usp_HKLaundryOrder_Select]			
	@OrderId INT =0,
    @OrdereDate DATETIME=NULL,
    @FolioNumber INT=NULL,
    @GuestID INT=NULL,
    @RoomNo INT=NULL,
	@OrderStatus INT =NULL,
	@userId int =null,  
	@LocationID int =null	
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
	
	IF @OrderId >0
		BEGIN
		
		  SELECT top(1) LO.[OrderId],LO.[OrdereDate],LO.[FolioNumber],rr.GuestID,rr.ReservationID,rr.ExpectedCheckIn,rr.ExpectedCheckOut,
				(select CD.FirstName + ' ' + CD.LastName FROM [contact].[Details] CD
					INNER JOIN [guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) AS  GuestName
					,PR.[RoomNo],LO.[TotalAmountBeforeTax]
					,LO.[Discount],LO.[ServiceCharge],LO.[TaxAmount],LO.[TotalAmountAfterTax],LO.[CashPaid],LO.[PINPaid]
					,LO.[ReturnAmount]--,LO.[OrderStatus]
					,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= LO.[OrderStatus]) AS OrderStatus
					--,LO.[PrintStatus]      
					,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= LO.[PrintStatus]) AS PrintStatus
					,LO.[Remarks]      ,LO.[CreatedBy]      ,LO.[Createdon]
					,LO.[ModifiedOn]      ,LO.[ModifiedBy]      ,LO.[IsExpress]      ,LO.[ItemCount]      ,LO.[IsActive], lo.LaundryType,
					(SELECT [ConfigValue] FROM [Housekeeping].[GuestTicketsConfig] where [ConfigCode]=lo.LaundryType) as LaundryTypeName,
					DATEADD(hour, 5, LO.[OrdereDate]) as DeliveryDateTime
					,(SELECT CA.Email FROM [contact].[Address] CA Inner join [contact].[Details] CD on CD.ContactID=CA.ContactID INNER JOIN [guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) as Email
                   ,(SELECT CA.PhoneNumber FROM [HMSYOGH].[contact].[Address] CA Inner join [contact].[Details] CD on CD.ContactID=CA.ContactID INNER JOIN [guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) as PhoneNumber,
					ReportFooter='This is proof of your transaction. It cannot be used to claim Tax. Please note this is not an Invoice A valid Invoice for Tax purpose can only be issued by the property '
		 FROM [Housekeeping].[HKLaundryOrder] LO
		  INNER JOIN reservation.Reservation rr on lo.FolioNumber=rr.FolioNumber
		  LEFT JOIN Products.Room PR ON LO.RoomNo=PR.RoomID
		 WHERE LO.[OrderId]= @OrderId --or LO.FolioNumber=@FolioNumber
		
		--Name,Quantity,ItemRateCleaning,ItemRatePress,ItemRateRepair,ExpressServiceCharge,TotalAmount
			
			SELECT 
					ROW_NUMBER() OVER(order by LOD.[ItemId]) as SlNo,LOD.[ItemId],
					SI.Name,
					LOD.[Quantity],LOD.RateClean,LOD.RatePress,
					LOD.RateRepair,LOD.[ExpresCharge],					
					format((LOD.RateClean + LOD.RatePress + LOD.RateRepair),'N2') as Rate,
					LOD.[TaxPer],
					LOD.[ServiceCharge],LOD.[ReturnStatus],LOD.[Remarks],
					--(LOD.RateClean + LOD.RatePress + LOD.RateRepair + LOD.ServiceCharge)*Quantity AS AmountAfterTax,
					--format(Quantity*(LOD.RateClean + LOD.RatePress + LOD.RateRepair + LOD.ServiceCharge) /(1+LOD.[TaxPer]),'N3') as TaxAmt
					format(Quantity*((LOD.RateClean + LOD.RatePress + LOD.RateRepair + LOD.ServiceCharge))+ (Quantity*(LOD.RateClean + LOD.RatePress + LOD.RateRepair + LOD.ServiceCharge)) *((LOD.[TaxPer]/100)),'N2')AS AmountAfterTax,
					format(Quantity*(LOD.RateClean + LOD.RatePress + LOD.RateRepair + LOD.ServiceCharge) *(LOD.[TaxPer]/100),'N3') as TaxAmt
				FROM [Housekeeping].[HKLaundryOrderDetails] LOD 
				INNER JOIN [Service].[Item] SI ON LOD.ItemId=SI.ItemID	
			    where LOD.OrderId=@OrderId
	
END	


END