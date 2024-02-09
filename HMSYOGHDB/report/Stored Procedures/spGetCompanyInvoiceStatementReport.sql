CREATE PROCEDURE [report].[spGetCompanyInvoiceStatementReport]
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
DECLARE @PAIDTYPE nvarchar(250);
DECLARE @PAYMENTTERMS nvarchar(250);
DECLARE @strCurrency NVARCHAR(150);


--SELECT @PAIDTYPE=[reservation].[fnGetPaidType] (@reservationId)

--SELECT @PAIDTYPE =  COALESCE(TM.TransactionMode + ',', '')  FROM [account].[TransactionMode] TM
--where TM.TransactionModeID in (SELECT DISTINCT TransactionModeID FROM  [account].[Transaction]	
--where reservationid=(select distinct r.ReservationID from reservation.Reservation r 
--			inner join  reservation.Invoice i on r.FolioNumber = i.FolioNumber
--			inner join  [guest].CompanyInvoiceStatementDetails c on i.InvoiceNo=c.InvoiceNo where c.CISID=@CISID))


SET @PAIDTYPE=ISNULL(@PAIDTYPE,'USD')

	
SET @PAYMENTTERMS = (SELECT CONCAT(CAST(GC.CreditPeriod AS NVARCHAR(100)), ' Days Credit, @', CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) , '% After Credit') FROM [guest].[GuestCompany] GC
INNER JOIN [guest].[CompanyInvoiceStatement] RR ON GC.CompanyID = RR.GuestCompanyID WHERE RR.CISID = @CISID)

set @CREATEDBY=(Select CD.FirstName from [guest].[CompanyInvoiceStatement]  gci
inner join app.[User] au on gci.CreatedBy=au.UserID
inner join [contact].[Details] CD on au.ContactID=CD.ContactID  where gci.CISID=@CISID)


DECLARE @GrossSales decimal (18,2)
DECLARE @Discounts decimal (18,2)
DECLARE @NetSalesAmount decimal (18,2)
DECLARE @Vat decimal (18,2)
DECLARE @TotalInclVAT decimal (18,2)
DECLARE @AdvanceCash decimal (18,2)
DECLARE @Balance decimal (18,2)
DECLARE @TotalInvoice int


	SELECT 
	 @GrossSales=SUM(RI.[TotalAmountBeforeTax])
	,@Discounts=SUM(RI.[AdditionalDiscount])
	,@NetSalesAmount=SUM(RI.[TotalAmountBeforeTax]) - SUM(RI.[AdditionalDiscount])
	,@Vat=SUM(RI.[ServiceTaxAmount])
	,@TotalInclVAT=SUM(RI.[TotalAmountBeforeTax]) - SUM(RI.[AdditionalDiscount]) + SUM(RI.[ServiceTaxAmount])
	,@AdvanceCash=SUM(RI.TotalReceived)
	,@Balance=((SUM(RI.[TotalAmountBeforeTax]) - SUM(RI.[AdditionalDiscount])) + SUM(RI.[ServiceTaxAmount]))-SUM(RI.TotalReceived)
	,@TotalInvoice=count(RI.InvoiceNo)
	FROM  [guest].[CompanyInvoiceStatement] gci
	Inner Join  [guest].CompanyInvoiceStatementDetails gcs ON gci.CISID=gcs.CISID
	INNER Join [reservation].[Invoice] RI ON gcs.InvoiceNo =RI.InvoiceNo WHERE gci.CISID=@CISID;




	Select
	FORMAT(gci.CISFromDate,'dd-MMM-yyyy hh:mm tt')as CISFromDate,
	FORMAT(gci.CISToDate,'dd-MMM-yyyy hh:mm tt')as CISToDate,
	Gcc.CompanyName,
	--gcc.CompanyAddress,
	(CASE When LEN(LTRIM(RTRIM(Gcc.CompanyAddress))) > 0 THEN LTRIM(RTRIM(Gcc.CompanyAddress)) +', ' ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyStreet))) > 0 THEN LTRIM(RTRIM(Gcc.CompanyStreet)) +', ' ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyCity))) > 0 THEN LTRIM(RTRIM(Gcc.CompanyCity)) +', ' ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(Gcc.CompanyState))  ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(Gcc.CompanyZIP))  ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(Gcc.CompanyPhoneNumber))  ELSE '' END)
	+ (CASE When LEN(LTRIM(RTRIM(Gcc.CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(Gcc.CompanyEmail))  ELSE '' END)  AS CompanyAddress
	,TotalAmtBeforeTax,
	gci.[Total Tax] As TotalTax,
	gci.TotalAmt,
	@CREATEDBY As CreatedBy

	,'8120.3.7087 (USD)' as USD
	,'8114.0.0343 (SRD)' as SRD
	,'8130.3.3111 (EURO)' as EURO
		
	,FORMAT(gci.CreatedOn,'dd MMM yyyy')as InvoiceDate

	,'Credit' as SalesType
	,@PAYMENTTERMS as PaymenTerm
	,@TotalInvoice as TotalInvoice

	,@GrossSales as GrossSales
	,@Discounts as Discounts
	,@NetSalesAmount as NetSalesAmount
	,@Vat as Vat
	,@TotalInclVAT as TotalInclVAT
	,@AdvanceCash as AdvanceCash
	,@Balance as Balance

	,''as CreatedBy
	,'' as CreatedOn
	from [guest].[CompanyInvoiceStatement] gci
	INNER JOIN guest.GuestCompany Gcc ON gci.GuestCompanyID=gcc.CompanyID where gci.CISID=@CISID
 


	SELECT  ROW_NUMBER() OVER (ORDER BY RI.[InvoiceNo]) AS IndexNumber,
	RS.ReservationID,
	RI.InvoiceNo,
	RI.InvoiceNumber,
	RI.TotalAmountBeforeTax,
	RI.AdditionalDiscount,
	RI.ServiceTaxAmount as VatAmount,
	RI.TotalAmountAfterTax,
	RI.TotalAmountNet

	,RI.TotalReceived as TotalReceived, 

	(RI.TotalAmountBeforeTax - RI.AdditionalDiscount + RI.ServiceTaxAmount  - RI.TotalReceived) as BalanceAmount



	FROM  [guest].[CompanyInvoiceStatement] gci
	Inner Join  [guest].CompanyInvoiceStatementDetails gcs ON gci.CISID=gcs.CISID
	INNER Join [reservation].[Invoice] RI ON gcs.InvoiceNo =RI.InvoiceNo			
	INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
	Where gci.CISID=@CISID
		 
	END
	 

