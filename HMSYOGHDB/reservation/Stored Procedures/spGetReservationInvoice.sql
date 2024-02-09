
CREATE PROCEDURE [reservation].[spGetReservationInvoice](		
	@FolioNumber int=null,
	@InvoiceNo int=null,
	@UserID int,	
	@LocationID int	,
	@FinalInvoice Bit
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @ReservationID INT;
	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualCheckOut datetime;
	DECLARE @ActualStay int;
	DECLARE @RateCurrencyID INT;
	DECLARE @VatAmount DECIMAL (8,2);
	DECLARE @ServiceTaxAmount DECIMAL (8,2);
	DECLARE @CREATEDBY nvarchar(100);
set @CREATEDBY=(Select CD.FirstName from [reservation].[Invoice]  RI
INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
			inner join app.[User] au on RI.CreatedBy=au.UserID
			inner join [contact].[Details] CD on au.ContactID=CD.ContactID where RI.InvoiceNo=@InvoiceNo)

	SELECT @ReservationID= ReservationID FROM [reservation].[Reservation] WHERE FolioNumber=@FolioNumber

	if @FinalInvoice = 1
		BEGIN
			SELECT RI.[InvoiceNo],FORMAT(RI.[InvoiceDate],'dd-MMM-yyyy')as [InvoiceDate], RI.[FolioNumber],RI.[GRCNo],RI.[GSTIN]      
					,RI.[TotalAmountBeforeTax],RI.[ServiceTaxAmount] as VatAmount,RI.[VatAmount] as ServiceTaxAmount,RI.[TotalAmountAfterTax],RI.[AdditionalDiscount],RI.[RoundOffAmount]
					,RI.[TotalAmountNet],RI.[InvoiceStatus] as InvoiceStatus,RI.[PrintStatus] as PrintStatus,RI.[Remarks],RI.[CreatedBy],@CREATEDBY AS CreatedByName,RI.[CreatedBy]
					,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
					,@ReservationID as ReservationID
					,RS.[GuestID]
					--gc.CompanyName  as BillTo,
					,CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo 
					,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName],	
					RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
					,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],								
						RT.[ReservationTypeID]	,RT.[ReservationType],RM.[ReservationMode],	
					RS.Rooms,RS.Nights,RS.Adults, RS.Children
					,AD.[PhoneNumber]
					,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
					+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address],
					(select GuestSignature from [reservation].[GuestSignature]  where InvoiceNo=@InvoiceNo) as GuestSignature,
					(select ManagerSignature from [reservation].[GuestSignature]  where InvoiceNo=@InvoiceNo) as ManagerSignature,
					RI.TotalReceived as ReceivedAmount,
					(select [reservation].[fnGetReserveredRoom](Rs.ReservationID)) as RoomNos
			FROM [reservation].[Invoice] RI
			INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			--inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID  -- 20-07-2023 vasanthakumar bug fixed
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			--inner join [general].[company] gc on rs.CompanyID=gc.CompanyID
			WHERE RI.InvoiceNo=@InvoiceNo --and RI.FolioNumber=@FolioNumber	
		
		 SELECT	FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			  RD.ServiceId as ItemId,
			  RD.ServiceDescription as ItemDescription,
			  RD.ServiceQty as Quantity,
			  RD.AmountBeforeTax AS Rate, 
			  RD.AmountAfterTax as Amount,
			  RD.TaxPercent as Tax,
			  RD.TaxAmount as TaxAmount
			  FROM [reservation].Invoice RS
			  inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			  WHERE RS.InvoiceNo=@InvoiceNo --and RS.LocationID = @LocationID
			  order by TransactionDate
		
		
		END
		-------------un commented by sravani on 28/07/2023--------------
     ELSE 
	 BEGIN
			SELECT RI.[InvoiceNo],FORMAT(RI.[InvoiceDate],'dd-MMM-yyyy')as [InvoiceDate],RI.[FolioNumber],RI.[GRCNo],RI.[GSTIN]      
					,RI.[TotalAmountBeforeTax],RI.[ServiceTaxAmount] as VatAmount,RI.[VatAmount] as ServiceTaxAmount,RI.[TotalAmountAfterTax],RI.[AdditionalDiscount],RI.[RoundOffAmount]
					,RI.[TotalAmountNet],RI.[InvoiceStatus] as InvoiceStatus,RI.[PrintStatus] as PrintStatus,RI.[Remarks],RI.[CreatedBy],@CREATEDBY AS CreatedByName
					,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
					,@ReservationID as ReservationID
					,RS.[GuestID],gc.CompanyName  as BillTo,

					TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName],	
					RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
					,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],								
						RT.[ReservationTypeID]	,RT.[ReservationType],RM.[ReservationMode],	
					RS.Rooms,RS.Nights,RS.Adults, RS.Children
					,AD.[PhoneNumber]
					,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
					+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address]
			,RI.TotalReceived as ReceivedAmount
			,'' as GuestSignature
			,'' as ManagerSignature,
			(select [reservation].[fnGetReserveredRoom](Rs.ReservationID)) as RoomNos
			FROM [reservation].[ProvisionalInvoice] RI
			INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			--inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID  -- 20-07-2023 vasanthakumar bug fixed
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			inner join [general].[company] gc on rs.CompanyID=gc.CompanyID
			WHERE RI.InvoiceNo=@InvoiceNo --and RI.FolioNumber=@FolioNumber	
		
		 SELECT	FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			  RD.ServiceId as ItemId,
			  RD.ServiceDescription as ItemDescription,
			  RD.ServiceQty as Quantity,
			  RD.AmountBeforeTax AS Rate, 
			  RD.AmountAfterTax as Amount,
			  RD.TaxPercent as Tax,
			  RD.TaxAmount as TaxAmount
			  FROM [reservation].ProvisionalInvoice RS
			  inner join [reservation].ProvisionalInvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			  WHERE RS.InvoiceNo=@InvoiceNo --and RS.LocationID = @LocationID
			  order by TransactionDate
		END
END		 
			
	


