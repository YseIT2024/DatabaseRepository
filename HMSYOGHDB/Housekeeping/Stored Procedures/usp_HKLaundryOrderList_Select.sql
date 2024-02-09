CREATE PROC [Housekeeping].[usp_HKLaundryOrderList_Select]			
	
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	

			
			SELECT DISTINCT LO.[OrderId],AT.AccountTypeID,LO.[OrdereDate],LO.[FolioNumber],rr.GuestID,rr.ReservationID,Format(rr.ExpectedCheckIn,'dd-MMM-yyyy') as ExpectedCheckIn,Format(rr.ExpectedCheckOut,'dd-MMM-yyyy') as ExpectedCheckOut,
				(select CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
					INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) AS  GuestName
					,PR.[RoomNo],LO.[TotalAmountBeforeTax]
					,LO.[Discount],LO.[ServiceCharge],LO.[TaxAmount],LO.[TotalAmountAfterTax],LO.[PINPaid]
					, LO.ReturnAmount,LO.[OrderStatus]-------(ISNULL(AT.Amount, 0) - LO.[TotalAmountAfterTax])
					,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= LO.[OrderStatus]) AS OrderStatus
					--,LO.[PrintStatus]      
					,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= LO.[PrintStatus]) AS PrintStatus
					,LO.[Remarks]      ,LO.[CreatedBy]      ,LO.[Createdon]
					,LO.[ModifiedOn]      ,LO.[ModifiedBy]      ,LO.[IsExpress]      ,LO.[ItemCount]      ,LO.[IsActive], lo.LaundryType,
					(SELECT [ConfigValue] FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] where [ConfigCode]=lo.LaundryType) as LaundryTypeName
					,(LO.[TotalAmountAfterTax]-LO.[TotalAmountBeforeTax]) as TaxAmt,
					(case when AT.AccountTypeID=93 then AT.Amount else 0 end) as CashPaid
		  FROM [HMSYOGH].[Housekeeping].[HKLaundryOrder] LO
		  INNER JOIN reservation.Reservation rr on lo.FolioNumber=rr.FolioNumber
		  LEFT JOIN Products.Room PR ON LO.RoomNo=PR.RoomID
		  Left Join account.[Transaction] AT on LO.OrderId=AT.ReferenceNo
		 WHERE RR.ReservationStatusID=3
		  ORDER BY LO.[OrderId]  DESC

END	

