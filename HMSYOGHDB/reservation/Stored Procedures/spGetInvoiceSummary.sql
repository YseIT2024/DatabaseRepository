-- =============================================
-- Author:		VASANTHAKUMAR.R
-- Create date: 17/08/2023
-- Description:	INVOICE SUMMARY REPORT
-- =============================================
CREATE PROCEDURE [reservation].[spGetInvoiceSummary] 
	 (
		 @InvoiceNo int
	 )
AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @CREATEDBY nvarchar(100);
	set @CREATEDBY=(Select CD.FirstName from [reservation].[Invoice]  RI
					INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
					inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
					inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
					inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
					inner join app.[User] au on RI.CreatedBy=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID where RI.InvoiceNo=@InvoiceNo)


			SELECT 
				 RI.[InvoiceNo]
				,RI.[InvoiceDate]
				,RI.[FolioNumber]
				,RI.[TotalAmountBeforeTax]
				,RI.[ServiceTaxAmount] as VatAmount
				,RI.[VatAmount] as ServiceTaxAmount
				,RI.[TotalAmountAfterTax]
				,RI.[RoundOffAmount]
				,RI.[TotalAmountNet]
				--,gc.CompanyName  as BillTo
				,CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo 
				,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
				,FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]
				,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
				,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]
				,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]
				,(SELECT  top(1) CC.CurrencyCode  FROM [reservation].[ReservedRoom] RRR inner join currency.Currency CC on RRR.RateCurrencyID = cc.CurrencyID where RRR.reservationid= RS.ReservationID) as Currency
				,(SELECT   ti.Title+' '+ cd.FirstName+' '+cd.LastName FROM  [general].[Employee] emp inner join contact.Details cd on emp.ContactID=cd.ContactID inner join guest.GuestLuggage  g on emp.EmployeeID = g.BellboyId inner join person.Title ti on cd.TitleID = ti.TitleID where ReservationStatusID=3 and ReservationID=RS.ReservationID) as CheckedInBy
				,(SELECT   ti.Title+' '+ cd.FirstName+' '+cd.LastName FROM  [general].[Employee] emp inner join contact.Details cd on emp.ContactID=cd.ContactID inner join guest.GuestLuggage  g on emp.EmployeeID = g.BellboyId inner join person.Title ti on cd.TitleID = ti.TitleID where ReservationStatusID=4 and ReservationID=RS.ReservationID) as CheckedOutBy
				,(SELECT TOP(1) TaxRate FROM  [reservation].[ReservationTaxDetails] RTD INNER JOIN [general].[Tax] GT on RTD.TaxID=GT.TaxID WHERE RTD.ReservationID=RS.ReservationID) as TaxPercentage
				,ISNULL(RI.TotalReceived,0) as Deposit
				,ISNULL(RI.[TotalAmountAfterTax] - RI.TotalReceived,0) as GrandTotal
				,@CREATEDBY AS CreatedByName
				--,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
				,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy')as [CreatedOn]
				FROM [reservation].[Invoice] RI
				INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
				inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
				inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
				inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
				inner join [person].[Title] TL on CD.TitleID = TL.TitleID
				--inner join [general].[company] gc on rs.CompanyID=gc.CompanyID
				WHERE RI.InvoiceNo=@InvoiceNo 


			SELECT 
			UPPER(ST.ServiceName) as ItemDescription,
			CASE 
			WHEN ID.BillingCode = 87 THEN CONCAT(SUM(id.ServiceQty), ' Nights') 
			ELSE CAST(SUM(id.ServiceQty) AS VARCHAR)   
		    END AS Quantity,
			CASE 
			WHEN ID.BillingCode = 87 THEN CONCAT(SUM(id.ServiceRate), ' /Person/Night') 
			ELSE CAST(SUM(id.ServiceRate) AS VARCHAR)   
		    END AS Rate
			,ID.TaxPercent as Tax,
			SUM(id.TaxAmount) AS TaxAmount,
			SUM(id.AmountBeforeTax) AS Amount,
			CASE 
				WHEN ID.BillingCode = 87 THEN
					(
					  'Room No '+(
						SELECT [reservation].[fnGetReserveredRoom](
							  (
								SELECT res.ReservationID 
								FROM reservation.Invoice inv
								INNER JOIN reservation.Reservation  res ON inv.FolioNumber = res.FolioNumber
								WHERE inv.InvoiceNo = @InvoiceNo
							  )
							)
						)
					)
				ELSE  
				''	
			END AS RoomNumber
			FROM 
			[reservation].InvoiceDetails ID
			INNER JOIN 
			service.Type ST ON ID.BillingCode = ST.ServiceTypeID
			WHERE 
			InvoiceNo = @InvoiceNo AND ST.ServiceName='ROOM CHARGES'
			GROUP BY 
			ST.ServiceName, ID.TaxPercent, ID.BillingCode
			UNION ALL
			SELECT 
			UPPER(ST.ServiceName) as ItemDescription,
			CASE 
			WHEN ID.BillingCode = 87 THEN CONCAT(SUM(id.ServiceQty), ' Nights') 
			ELSE CAST(SUM(id.ServiceQty) AS VARCHAR)   
		    END AS Quantity,
			CASE 
			WHEN ID.BillingCode = 87 THEN CONCAT(SUM(id.ServiceRate), ' /Person/Night') 
			ELSE CAST(SUM(id.ServiceRate) AS VARCHAR)   
		    END AS Rate
			,ID.TaxPercent as Tax,
			SUM(id.TaxAmount) AS TaxAmount,
			SUM(id.AmountBeforeTax) AS Amount,
			CASE 
				WHEN ID.BillingCode = 87 THEN
					(
					  'Room No '+(
						SELECT [reservation].[fnGetReserveredRoom](
							  (
								SELECT res.ReservationID 
								FROM reservation.Invoice inv
								INNER JOIN reservation.Reservation  res ON inv.FolioNumber = res.FolioNumber
								WHERE inv.InvoiceNo = @InvoiceNo
							  )
							)
						)
					)
				ELSE  
				''	
			END AS RoomNumber
			FROM 
			[reservation].InvoiceDetails ID
			INNER JOIN 
			service.Type ST ON ID.BillingCode = ST.ServiceTypeID
			WHERE 
			InvoiceNo = @InvoiceNo AND ST.ServiceName!='ROOM CHARGES'
			GROUP BY 
			ST.ServiceName, ID.TaxPercent, ID.BillingCode


			select GuestSignature,ManagerSignature from [reservation].[GuestSignature] where InvoiceNo=@InvoiceNo and IsActive=1
END

