CREATE PROCEDURE [reservation].[spGetReservationInvoiceList](		
	@Datefrom DATE=null,
	@DateTo DATE=null,
	@UserId int=null,
	@BillTo int=null
	
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	Declare @PaidAmount decimal (10,4)=0
	Declare @BalanceAmount decimal (10,4)=0

	--IF @BillTo is not null     -----------> DONE BY MURUGESH S -------------
	IF @BillTo > 0
	begin
		SELECT ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,RI.InvoiceNo,  
			RI.InvoiceDate,RI.FolioNumber,RI.GuestID,RI.GRCNo,
			RI.GSTIN,RI.TotalAmountBeforeTax,RI.VatAmount,RI.ServiceTaxAmount,
			RI.TotalAmountAfterTax,RI.AdditionalDiscount,RI.RoundOffAmount,RI.TotalAmountNet,
			@PaidAmount as PaidAmount, RI.TotalAmountNet-@PaidAmount as BalanceAmount,
			RI.InvoiceStatus,RI.PrintStatus,RI.Remarks,RI.CreatedBy,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn],
			GT.ContactID,
			TL.Title + ' ' + CD.FirstName + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.LastName ELSE '' END) AS [GuestName],
			
			CASE
			WHEN RI.ParentInvoiceNo IS NOT NULL THEN ISNULL(CAST(RI.InvoiceNo as VARCHAR(20)),'') +' - '+ ISNULL(CAST(RI.ParentInvoiceNo as varchar(20)),'')
			ELSE   CAST(RI.InvoiceNo as VARCHAR(20))
			END as ParentInvoiceNo,
			--RI.InvoiceNo as ParentInvoiceNo
			--rg.GuestSignature as IsGuestSignature,
			--rg.ManagerSignature as IsManagerSignature
			rg.GuestSignature ,
				CASE 
					WHEN LEN(rg.GuestSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsGuestSignature			
			,rg.ManagerSignature,
				CASE 
					WHEN LEN(rg.ManagerSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsManagerSignature		
             -------New Column Added by Sravani
            --,isnull((select case when ISNULL(g.GuestSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsGuestSignature
           -- ,isnull((select case when ISNULL(g.ManagerSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsManagerSignature
			--,(select GuestSignature from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsGuestSignature
			--,(select ManagerSignature from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsManagerSignature
			,case when RI.InvoiceNumber is null then  CONVERT(NVARCHAR(20), ri.InvoiceNo)
			--(select top(1) p.ProformaInvoiceNo from reservation.ProformaInvoice p inner join reservation.Reservation r on p.ReservationId=r.ReservationID where r.FolioNumber=RI.FolioNumber and p.DocumentTypeId=2) 
			else RI.InvoiceNumber  end InvoiceNumber,RR.ReservationID
			FROM  [reservation].[Invoice] RI
			INNER JOIN reservation.Reservation RR ON RI.FolioNumber=RR.FolioNumber--ADDED RAjendra
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			LEFT join [reservation].[GuestSignature] rg on ri.InvoiceNo=rg.InvoiceNo
			WHERE RI.InvoiceDate>=@Datefrom and RI.InvoiceDate<=@DateTo and RI.BillTo=@BillTo and RI.InvoiceNo NOT IN (select InvoiceNo from [guest].CompanyInvoiceStatementDetails)
			ORDER BY  RI.InvoiceNo DESC

	end

else
	IF @Datefrom is not null	
		Begin
			SELECT ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,RI.InvoiceNo,  
			RI.InvoiceDate,RI.FolioNumber,RI.GuestID,RI.GRCNo,
			RI.GSTIN,RI.TotalAmountBeforeTax,RI.VatAmount,RI.ServiceTaxAmount,
			RI.TotalAmountAfterTax,RI.AdditionalDiscount,RI.RoundOffAmount,RI.TotalAmountNet,
			@PaidAmount as PaidAmount, RI.TotalAmountNet-@PaidAmount as BalanceAmount,
			RI.InvoiceStatus,RI.PrintStatus,RI.Remarks,RI.CreatedBy,RI.Createdon,
			GT.ContactID,
			TL.Title + ' ' + CD.FirstName + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.LastName ELSE '' END) AS [GuestName],
			
			CASE
			WHEN RI.ParentInvoiceNo IS NOT NULL THEN ISNULL(CAST(RI.InvoiceNo as VARCHAR(20)),'') +' - '+ ISNULL(CAST(RI.ParentInvoiceNo as varchar(20)),'')
			ELSE   CAST(RI.InvoiceNo as VARCHAR(20))
			END as ParentInvoiceNo,
			--RI.InvoiceNo as ParentInvoiceNo
			--rg.GuestSignature as IsGuestSignature,
			--rg.ManagerSignature as IsManagerSignature
			rg.GuestSignature ,
				CASE 
					WHEN LEN(rg.GuestSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsGuestSignature			
			,rg.ManagerSignature,
				CASE 
					WHEN LEN(rg.ManagerSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsManagerSignature		
            -----New Column Added by Sravani
          --,isnull((select case when ISNULL(g.GuestSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsGuestSignature
          -- ,isnull((select case when ISNULL(g.ManagerSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsManagerSignature

			--,(select GuestSignature from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsGuestSignature
			--,(select ManagerSignature from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsManagerSignature
			,case when RI.InvoiceNumber is null then  CONVERT(NVARCHAR(20), ri.InvoiceNo)
			--(select top(1) p.ProformaInvoiceNo from reservation.ProformaInvoice p inner join reservation.Reservation r on p.ReservationId=r.ReservationID where r.FolioNumber=RI.FolioNumber and p.DocumentTypeId=2) 
			else RI.InvoiceNumber  end InvoiceNumber,RR.ReservationID--ADDED RAJENDRA Reservation Id
			FROM  [reservation].[Invoice] RI
			INNER JOIN reservation.Reservation RR ON RI.FolioNumber=RR.FolioNumber--ADDED RAjendra
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			LEFT join [reservation].[GuestSignature] rg on ri.InvoiceNo=rg.InvoiceNo
			WHERE RI.InvoiceDate>=@Datefrom and RI.InvoiceDate<=@DateTo	
			ORDER BY  RI.InvoiceNo DESC
		 END
	ELSE
			SELECT ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,RI.InvoiceNo,  
			RI.InvoiceDate,RI.FolioNumber,RI.GuestID,RI.GRCNo,
			RI.GSTIN,RI.TotalAmountBeforeTax,RI.VatAmount,RI.ServiceTaxAmount,
			RI.TotalAmountAfterTax,RI.AdditionalDiscount,RI.RoundOffAmount,RI.TotalAmountNet,
			@PaidAmount as PaidAmount, RI.TotalAmountNet-@PaidAmount as BalanceAmount,
			RI.InvoiceStatus,RI.PrintStatus,RI.Remarks,RI.CreatedBy,RI.Createdon,
			GT.ContactID,
			TL.Title + ' ' + CD.FirstName + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.LastName ELSE '' END) AS [GuestName],
			
			CASE
			WHEN RI.ParentInvoiceNo IS NOT NULL THEN ISNULL(CAST(RI.InvoiceNo as VARCHAR(20)),'') +' - '+ ISNULL(CAST(RI.ParentInvoiceNo as varchar(20)),'')
			ELSE   CAST(RI.InvoiceNo as VARCHAR(20))
			END as ParentInvoiceNo,
			rg.GuestSignature ,
				CASE 
					WHEN LEN(rg.GuestSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsGuestSignature			
			,rg.ManagerSignature,
				CASE 
					WHEN LEN(rg.ManagerSignature) > 0 THEN '1'
					ELSE '0'
				END AS IsManagerSignature		


--			SELECT OrderID, Quantity,
--CASE
--    WHEN Quantity > 30 THEN 'The quantity is greater than 30'
--    WHEN Quantity = 30 THEN 'The quantity is 30'
--    ELSE 'The quantity is under 30'
--END AS QuantityText

			--,rg.ManagerSignature as IsManagerSignature
			--RI.InvoiceNo as ParentInvoiceNo
            -----New Column Added by Sravani
           -- ,isnull((select case when ISNULL(g.GuestSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsGuestSignature
           -- ,isnull((select case when ISNULL(g.ManagerSignature,'') = '' then '0' else '1' end from reservation.Invoice i inner join  reservation.GuestSignature g on i.InvoiceNo=g.InvoiceNo where g.IsActive=1 and i.InvoiceNo=RI.InvoiceNo  and ISNULL(i.ParentInvoiceNo,'')=''),'0') as IsManagerSignature
			--CASE
			--	WHEN Quantity > 30 THEN 'The quantity is greater than 30'
			--	 WHEN Quantity = 30 THEN 'The quantity is 30'
			--	ELSE 'The quantity is under 30'
			--END AS QuantityText
				
		--	,(select GuestSignature  from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsGuestSignature
		--	,(select ManagerSignature from reservation.GuestSignature where InvoiceNo=RI.InvoiceNo) as IsManagerSignature

			,case when RI.InvoiceNumber is null then CONVERT(NVARCHAR(20), ri.InvoiceNo)  
			--(select top(1) p.ProformaInvoiceNo from reservation.ProformaInvoice p inner join reservation.Reservation r on p.ReservationId=r.ReservationID where r.FolioNumber=RI.FolioNumber and p.DocumentTypeId=2) 
			else RI.InvoiceNumber  end InvoiceNumber,RR.ReservationID
			FROM  [reservation].[Invoice] RI
			INNER JOIN reservation.Reservation RR ON RI.FolioNumber=RR.FolioNumber--ADDED RAjendra
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			LEFT JOIN [reservation].[GuestSignature] rg on ri.InvoiceNo=rg.InvoiceNo
			ORDER BY  RI.InvoiceNo DESC
				
END
