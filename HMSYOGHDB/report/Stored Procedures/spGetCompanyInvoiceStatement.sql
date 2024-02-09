


create PROCEDURE [report].[spGetCompanyInvoiceStatement]
(

	@CISID int=0,
	@UserId int=null,
	@locationID INT=0
)
AS
BEGIN
	SET NOCOUNT ON;
    Declare @PaidAmount decimal (10,4)=0
	Declare @BalanceAmount decimal (10,4)=0
	DECLARE @CREATEDBY nvarchar(100);
	--DECLARE @PrintBy nvarchar(100);
	set @CREATEDBY=(Select CD.FirstName from [guest].[CompanyInvoiceStatement]  gci
					inner join app.[User] au on gci.CreatedBy=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID  where gci.CISID=@CISID)

	begin

	Select FORMAT(gci.CISFromDate,'dd-MMM-yyyy hh:mm tt')as CISFromDate,FORMAT(gci.CISToDate,'dd-MMM-yyyy hh:mm tt')as CISToDate,
	Gcc.CompanyName,gcc.CompanyAddress,TotalAmtBeforeTax,gci.[Total Tax]As TotalTax,gci.TotalAmt,@CREATEDBY As CreatedBy,FORMAT(gci.CreatedOn,'dd-MMM-yyyy hh:mm tt')as CreatedOn
	from [guest].[CompanyInvoiceStatement] gci
	INNER JOIN guest.GuestCompany Gcc ON gci.GuestCompanyID=gcc.CompanyID where gci.CISID=@CISID
  
	SELECT  ROW_NUMBER() OVER (ORDER BY RI.[InvoiceNo]) AS IndexNumber,
	RI.[InvoiceNo],RI.[InvoiceDate],RI.[FolioNumber],RI.[GRCNo],RI.[GSTIN]      
					,RI.[TotalAmountBeforeTax],RI.[ServiceTaxAmount] as VatAmount,RI.[VatAmount] as ServiceTaxAmount,RI.[TotalAmountAfterTax],RI.[AdditionalDiscount],RI.[RoundOffAmount]
					,RI.[TotalAmountNet],RI.[InvoiceStatus] as InvoiceStatus,RI.[PrintStatus] as PrintStatus,RI.[Remarks],RI.[CreatedBy],RI.[CreatedBy]
					,FORMAT(RI.[CreatedOn],'dd-MMM-yyyy hh:mm tt')as [CreatedOn]
					,@PaidAmount as PaidAmount, RI.TotalAmountNet-@PaidAmount as BalanceAmount
					,RS.[GuestID]
					--gc.CompanyName  as BillTo,
					,CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo 
					,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName],	
					FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
					,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],								
						RT.[ReservationTypeID]	,RT.[ReservationType],RM.[ReservationMode],	
					RS.Rooms,RS.Nights,RS.Adults, RS.Children
					,AD.[PhoneNumber]
					,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
					+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END) as [Address],
			
					RI.TotalReceived as ReceivedAmount
			FROM  [guest].[CompanyInvoiceStatement] gci
			Inner Join  [guest].CompanyInvoiceStatementDetails gcs ON gci.CISID=gcs.CISID
			INNER Join [reservation].[Invoice] RI ON gcs.InvoiceNo =RI.InvoiceNo			
			INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			--inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID  -- 20-07-2023 vasanthakumar bug fixed
			inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID	Where	gci.CISID=@CISID
			
	
	END

END