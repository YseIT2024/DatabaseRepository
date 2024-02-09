CREATE PROCEDURE [reservation].[spGerCurrentAccountDetails]
(
	@Datefrom date,
	@DateTo date,
	@BillTo int,
	@GuestType nvarchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Declare @Datefrom date='2023-10-22';
--Declare @DateTo date='2023-11-22';
--Declare @BillTo int=48;
--Declare @GuestType nvarchar(50);
 
Declare @AdditionalDiscount decimal (18,2)=10
Declare @ServiceTypeID int=18;
Declare @CompanyName nvarchar(150);
if(@GuestType='Guest')
begin
set @CompanyName=(select CONCAT(T.Title,' ',D.FirstName,' ',D.LastName) from [guest].[Guest] g 
		INNER JOIN [contact].[Details] D ON g.ContactID = d.ContactID
		INNER JOIN [person].[Title] T ON D.TitleID = T.TitleID where g.GuestID=@BillTo)
end
else
begin
 set @CompanyName=(select CompanyName from [guest].[GuestCompany] where CompanyID=@BillTo)
end
Declare @CompanyReservationType nvarchar(150)=(select ReservationType from [guest].[GuestCompany] gc
 inner join reservation.ReservationType rt on gc.ReservationTypeId =rt.ReservationTypeID where CompanyID=@BillTo)

  
declare @TempTable Table(ID INT IDENTITY(1, 1),
DSeq int,
RowNo int, 
InvoiceNo int,
TransactionDate date,
Particulars varchar(500),
Debit decimal(18,2),
Credit decimal(18,2),
TotalB decimal(18,2))

if(@GuestType='Company')
begin
insert into @TempTable
		SELECT 1,
		ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,
		RI.InvoiceNo,
		format(RI.InvoiceDate,'dd-MMM-yyyy') as InvoiceDate,
		--(select ReservationType from  reservation.ReservationType where ReservationTypeID=RR.ReservationTypeID )+
		'Yogh Booking Nr '+ CONVERT(NVARCHAR(50), RI.FolioNumber)+', '+ CONVERT(NVARCHAR(50), RR.Nights)+ ' night '+ 
		CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID))
		+', '+@CompanyName+ ', booking reservation # '+ CONVERT(NVARCHAR(50), rr.ReservationID) +', Guest : '
		+TL.Title + ' ' + CD.FirstName + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.LastName ELSE '' END) +', Invoice Nr '+CONVERT(NVARCHAR(50), RI.InvoiceNo)  as Explanation
		,RI.TotalAmountNet as Debit
		,0 as Credit
		,-RI.TotalAmountNet as Balance
		--,0 as DebitOrCredit
		FROM  [reservation].[Invoice] RI
		inner join reservation.Reservation RR on ri.FolioNumber=RR.FolioNumber
		--inner join reservation.ProformaInvoice PR ON RR.ReservationID=PR.ReservationId AND PR.DocumentTypeId=2 and PR.Type='Company'
		inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		 
WHERE CONVERT(datetime, RI.InvoiceDate, 103) >= CONVERT(datetime, @Datefrom, 103) and  CONVERT(datetime, RI.InvoiceDate, 103)<= CONVERT(datetime, @DateTo, 103) 
and RI.BillTo=@BillTo AND RR.SalesTypeID=2
		--and	RI.InvoiceNo NOT IN (select InvoiceNo from [guest].CompanyInvoiceStatementDetails)
		 
		union all
		SELECT 2,
		ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,
		 RI.InvoiceNo,
		format(RI.InvoiceDate,'dd-MMM-yyyy') as InvoiceDate,
		--'Compensation  ' +   @CompanyName+' ('+
		--CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) +'-('+ 
		--CONVERT(NVARCHAR(50),CAST(RR.AdditionalDiscount AS DECIMAL(18, 2))) +'%' + 
		--CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) +')*('+
		--CONVERT(NVARCHAR(50),CAST(isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0) AS DECIMAL(18, 2)))+'%)*('+
		--CONVERT(NVARCHAR(50),RR.Nights) +') '  as Explanation
'Compensation  ' +   @CompanyName+' ('+
CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) +' - '+ 
CONVERT(NVARCHAR(50),CAST(RR.AdditionalDiscount AS DECIMAL(18, 2))) +'% Discount ) = Net Sales ' + 
CONVERT(NVARCHAR(50),CAST(((select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID) - RR.AdditionalDiscount / 100 * (select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) AS DECIMAL(18, 2)))
+'-'+
 
CONVERT(NVARCHAR(50),CAST(isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0) AS DECIMAL(18, 2)))+'% '
  as Explanation


		,0 as Debit
		,((RI.TotalAmountNet-ISNULL(RR.AdditionalDiscountAmount,0))* (isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0)) / 100) as Credit
		,((RI.TotalAmountNet-ISNULL(RR.AdditionalDiscountAmount,0))* (isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0)) / 100) as Balance
		--,0 as DebitOrCredit
		FROM  [reservation].[Invoice] RI
		inner join reservation.Reservation RR on ri.FolioNumber=RR.FolioNumber
		WHERE CONVERT(datetime, RI.InvoiceDate, 103) >=  CONVERT(datetime, @Datefrom, 103)  and CONVERT(datetime, RI.InvoiceDate, 103) <= CONVERT(datetime, @DateTo, 103)  
		and RI.BillTo=@BillTo AND RR.SalesTypeID=2
		--and	RI.InvoiceNo NOT IN (select InvoiceNo from [guest].CompanyInvoiceStatementDetails)
		 

		select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,InvoiceNo,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTable order by TransactionDate,InvoiceNo,DSeq --1
	
end
else
begin
insert into @TempTable
		SELECT 1,
		ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,
		RI.InvoiceNo,
		format(RI.InvoiceDate,'dd-MMM-yyyy') as InvoiceDate,
		'Yogh Booking Nr'+ CONVERT(NVARCHAR(50), RI.FolioNumber)+', '+ CONVERT(NVARCHAR(50), RR.Nights)+ ' night '+ 
		CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID))
		--+', '+@CompanyName+ ', booking reservation # '+ CONVERT(NVARCHAR(50), rr.ReservationID) 
		+', Guest : '
		+TL.Title + ' ' + CD.FirstName + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.LastName ELSE '' END) +', Invoice Nr '+CONVERT(NVARCHAR(50), RI.InvoiceNo)  as Explanation
		,RI.TotalAmountNet  as Debit
		,0 as Credit
		,-RI.TotalAmountNet as Balance
		--,0 as DebitOrCredit
		FROM  [reservation].[Invoice] RI
		inner join reservation.Reservation RR on ri.FolioNumber=RR.FolioNumber
		--inner join reservation.ProformaInvoice PR ON RR.ReservationID=PR.ReservationId AND PR.DocumentTypeId=2 and PR.Type='Company'
		inner join [guest].[Guest] GT on RI.GuestID = GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		 
WHERE CONVERT(datetime, RI.InvoiceDate, 103) >= CONVERT(datetime, @Datefrom, 103) 
and  CONVERT(datetime, RI.InvoiceDate, 103)<= CONVERT(datetime, @DateTo, 103) and RI.BillTo=@BillTo and RR.SalesTypeID=2  and RR.ReservationTypeID=1
		 AND RR.SalesTypeID=2
		 
		--union all
		--	SELECT 2,
		--ROW_NUMBER() OVER(ORDER BY RI.InvoiceNo ASC) AS RowNo,
		-- RI.InvoiceNo,
		--format(RI.InvoiceDate,'dd-MMM-yyyy') as InvoiceDate,
	 
		--'Compensation  ' +   @CompanyName+' ('+
		--CONVERT(NVARCHAR(50),(select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) +' - '+ 
		--CONVERT(NVARCHAR(50),CAST(RR.AdditionalDiscount AS DECIMAL(18, 2))) +'% Discount ) = Net Sales ' + 
		--CONVERT(NVARCHAR(50),CAST(((select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID) - RR.AdditionalDiscount / 100 * (select top(1) AmountAfterTax from reservation.InvoiceDetails where InvoiceNo=RI.InvoiceNo and BillingCode=@ServiceTypeID)) AS DECIMAL(18, 2)))
		--+'-'+
		--case when @GuestType='Guest' then '0% Commission'
		--else 
		--CONVERT(NVARCHAR(50),CAST(isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0) AS DECIMAL(18, 2)))+'% Commission'
		--end +') '  as Explanation


		--,0 as Debit
		--,((RI.TotalAmountNet-ISNULL(RR.AdditionalDiscountAmount,0))* (isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0)) / 100) as Credit
		--,((RI.TotalAmountNet-ISNULL(RR.AdditionalDiscountAmount,0))* (isnull((SELECT top(1) CommissionPercentage  FROM [HMSYOGH].[guest].[GuestCompanyRateContract] WHERE GuestCompanyID=@BillTo and IsActive=1 order by 1 desc),0)) / 100) as Balance
		----,0 as DebitOrCredit
		--FROM  [reservation].[Invoice] RI
		--inner join reservation.Reservation RR on ri.FolioNumber=RR.FolioNumber
		--WHERE CONVERT(datetime, RI.InvoiceDate, 103) >=  CONVERT(datetime, @Datefrom, 103)  and CONVERT(datetime, RI.InvoiceDate, 103) <= CONVERT(datetime, @DateTo, 103)  and RI.BillTo=@BillTo
		----and	RI.InvoiceNo NOT IN (select InvoiceNo from [guest].CompanyInvoiceStatementDetails)
		 

		select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,InvoiceNo,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTable order by TransactionDate,InvoiceNo,DSeq --1
	
end

END

