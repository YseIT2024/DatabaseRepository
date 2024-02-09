CREATE PROCEDURE [reservation].[spGetOtaLedgerDetails] --14588,1,1,3
(	
    @FolioNo int null,	
	@LocationID int,
	@DrawerID int=null,
	@UserId int
)
AS
Begin
SET NOCOUNT ON;
  
	DECLARE @ReservationNo int=0;
	Declare @reservationId int;    
    DECLARE @BOOKEDBY nvarchar(100);
	DECLARE @CHECKEDINBY nvarchar(100);
	DECLARE @CHECKEDOUTBY nvarchar(100);
	DECLARE @PAIDCURRENCY nvarchar(250);
	DECLARE @PAIDTYPE nvarchar(250);
	DECLARE @TOTALNIGHTS nvarchar(250);
	DECLARE @RATEEURO nvarchar(250);
	DECLARE @RATESRD nvarchar(250);
	DECLARE @REFUNDAMT DECIMAL (18,4);
	DECLARE @RESERVATIONMODE INT;
	DECLARE @INVOICENO INT;
	DECLARE @SERVICETYPEID INT =18;
	DECLARE @OCCUPANCY INT=0;
	Declare @GUESTNOTES nvarchar(250);
	Declare @REMARKS nvarchar(250);
	DECLARE @PAYMENTTERMS nvarchar(250);
	DECLARE @TAXEXCEMPTION nvarchar(250);
	DECLARE @BASERATE DECIMAL (18,4);
	DECLARE @BeforeTaxGuest DECIMAL (18,4);
	DECLARE @AfterTaxGuest DECIMAL (18,4);
	DECLARE @TaxGuest DECIMAL (18,4);
	DECLARE @BalanceGuest DECIMAL(18,4);
	DECLARE @BeforeTaxOTA DECIMAL (18,4);
	DECLARE @AfterTaxOTA DECIMAL (18,4);
	DECLARE @TaxOTA DECIMAL (18,4);
	DECLARE @BalanceOTA DECIMAL(18,4);
	DECLARE @DISCOUNTPERCENTAGE decimal(18,2);
	DECLARE @DISCOUNTAMOUNT decimal(18,2);
	DECLARE @ENDDATE DATE;
	DECLARE @CONFIRMEDDATE DATETIME;
	DECLARE @ROOMTYPEPE nvarchar(250);
	DECLARE @ApprovedBy nvarchar(100);
	-----------------------------------------------Rajendra Added
	DECLARE @ExpectedCheckIn nvarchar(250);
	DECLARE @ExpectedCheckOut nvarchar(250);
	DECLARE @GuestName nvarchar(250);
	DECLARE @ExpectedCheckInTime Time;
	DECLARE @ExpectedCheckOutTime Time;
	DECLARE @ReservationType nvarchar(250);
	DECLARE @ProfomaInvoice int;
	DECLARE @BillTo nvarchar(250);
	DECLARE @GuestId int;
	DECLARE @OTAId int;
	DECLARE @SALETYPE nvarchar(250);

	
	set @reservationId= (Select ReservationID from reservation.Reservation where FolioNumber=@FolioNo)
	Set @ExpectedCheckIn=(Select TOP 1 FORMAT(ExpectedCheckIn, 'dd-MMM') as FormattedDate from Reservation.Reservation Where ReservationID=@reservationId)
	Set @ExpectedCheckOut=(Select TOP 1 FORMAT(ExpectedCheckOut, 'dd-MMM') as FormattedDate from Reservation.Reservation Where ReservationID=@reservationId)
	select  @RESERVATIONMODE=ReservationModeID from  reservation.Reservation where FolioNumber=@FolioNo
	Set @GuestId = (SELECT GuestId FROM Reservation.Reservation where ReservationID=@reservationId)
	Set @OTAId= (SELECT CompanyTypeID FROM Reservation.Reservation where ReservationID=@reservationId)
	SET @ExpectedCheckInTime = ( SELECT TOP 1 FORMAT(ExpectedCheckIn, 'hh:mm') AS FormattedTime FROM Reservation.Reservation
			WHERE ReservationID = @reservationId);	
	SET @ExpectedCheckOutTime = (SELECT TOP 1 FORMAT(ExpectedCheckOut, 'hh:mm') AS FormattedTime FROM Reservation.Reservation
			WHERE ReservationID = @reservationId);

	Set @GuestName=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from Reservation.Reservation  RI					
					inner join [guest].[Guest] GG on RI.GuestID=GG.GuestID
					INNER JOIN [contact].[Details] CD ON GG.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.ReservationID=@reservationId)
	
   select @ReservationNo=reservationid  from reservation.Reservation where FolioNumber=@FolioNo  

	Set @ReservationType=(SELECT TOP 1 RM.ReservationMode FROM Reservation.Reservation RR
	INNER JOIN reservation.ReservationMode RM ON RR.ReservationModeID=RM.ReservationModeID
    WHERE ReservationID = @reservationId)

	Set @ProfomaInvoice=(Select  TOP 1 ProformaInvoiceId from [reservation].[ProformaInvoice] Where ReservationID=@reservationId)

	SET @BillTo = (
    SELECT TOP 1 CASE
        WHEN RR.CompanyID = 1 THEN 'Guest'
        ELSE GC.CompanyName
    END AS BillTo
    FROM Reservation.Reservation RR
    INNER JOIN [guest].[GuestCompany] GC ON GC.CompanyID = RR.CompanyTypeID
    WHERE RR.ReservationID = @reservationId)

	SET @SALETYPE =(SELECT rs.SalesType FROM [HMSYOGH].[reservation].[SalesTypes] rs
	INNER join reservation.Reservation rr on rs.SalesTypeID=rr.SalesTypeID 
	where rr.ReservationID=@reservationId)

	SET @ROOMTYPEPE = (select top 1[reservation].[fnGetRoomCategory](@ReservationId))
	SET @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationId)
	
	set @BOOKEDBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.ReservationID=@reservationId And RI.ReservationStatusID=1)
					
   SET @OCCUPANCY = (SELECT Adults + Children FROM reservation.Reservation WHERE ReservationID = @reservationId);	
   --SET @GUESTNOTES=(select Note from [reservation].[Note] where ReservationID=@reservationId and NoteTypeID=3)
   --SET @REMARKS=(select Note from [reservation].[Note] where ReservationID=@reservationId and NoteTypeID=4)
    SET @PAYMENTTERMS = (SELECT  CONCAT( 
	        CASE 
                WHEN GC.CreditPeriod IS NULL THEN '0'
                WHEN GC.CreditPeriod = 0 THEN '0'
                ELSE CAST(GC.CreditPeriod AS NVARCHAR(100))
            END, 
	        ' Days Credit, @', 
            CASE 
                WHEN GC.IntrestPercentageAfterCreditPeriod IS NULL THEN '0%'
                WHEN GC.IntrestPercentageAfterCreditPeriod = 0 THEN '0%'
                ELSE CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) + '%'
            END,
            ' After Credit')FROM [guest].[GuestCompany] GC
			INNER JOIN [reservation].[Reservation] RR ON GC.CompanyID = RR.CompanyTypeID  WHERE RR.ReservationID = @reservationId)

   SET @TAXEXCEMPTION = (SELECT top 1 TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@reservationId)

    IF (@RESERVATIONMODE>=4)
	Begin
		Set @BOOKEDBY='Online'
	End

   SELECT @INVOICENO=INVOICENO FROM reservation.Invoice WHERE FolioNumber=@FolioNo AND ParentInvoiceNO IS NULL
   
   set @CHECKEDINBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=3)
   set @CHECKEDOUTBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=4)
   set @ApprovedBy=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from [reservation].[ApprovalLog]  RI
					inner join app.[User] au on RI.ModifiedBy=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.RefrenceNo=@reservationId)
 SELECT @PAIDCURRENCY= ISNULL([reservation].[fnGetPaidCurrency](@reservationId), 'USD')
 SELECT @RATEEURO= [Rate] FROM [HMSYOGH].[currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT(AccountingDate,'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=3
 SELECT @RATESRD=  [Rate] FROM [HMSYOGH].[currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT([AccountingDate],'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=2
 SELECT @TOTALNIGHTS= NIGHTS FROM reservation.Reservation where RESERVATIONID=@reservationId
 SELECT @PAIDTYPE=[reservation].[fnGetPaidType] (@reservationId)
 SET @PAIDTYPE=ISNULL(@PAIDTYPE,'USD')
 
 
declare @TempTableGust Table(ID INT IDENTITY(1, 1),DSeq int,ReservationId int,TransactionDate datetime,Particulars varchar(500),TransactionType varchar(50),VoucherNo int,Debit decimal(18,2),Credit decimal(18,2),TotalB decimal(18,2))
declare @TempTableOTA Table(ID INT IDENTITY(1, 1),DSeq int,ReservationId int,TransactionDate datetime,Particulars varchar(500),TransactionType varchar(50),VoucherNo int,Debit decimal(18,2),Credit decimal(18,2),TotalB decimal(18,2))

 Declare @RoomNo varchar(250) =(select [reservation].[fnGetReserveredRoom] (@ReservationNo))


DECLARE @NewQueryReservationId int =6580
DECLARE @IsNewQuery int=0;
		
IF((select ReservationID from reservation.Reservation where FolioNumber=@FolioNo) > @NewQueryReservationId)
	BEGIN
		SET @IsNewQuery=1;
	END

IF(@IsNewQuery=0)
	BEGIN   --- Old Query
	 set @REFUNDAMT=(select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId)
	 SET @BASERATE=(SELECT TOP 1 UnitPriceBeforeDiscount from reservation.ReservationDetails where ReservationID=@ReservationId)
   

 SELECT @DISCOUNTAMOUNT=AdditionalDiscountAmount,@DISCOUNTPERCENTAGE=AdditionalDiscount,@ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationId
  SET @TaxGuest = (SELECT SUM(gld.AmtTax ) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ) );
  SET @BeforeTaxGuest = (SELECT SUM((gld.AmtBeforeTax)) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ));
  SET @AfterTaxGuest = (SELECT SUM(gld.AmtAfterTax) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ));

   SET @BalanceGuest=
    CASE 
        WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTaxGuest, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
        ELSE (ISNULL(@AfterTaxGuest, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
    END

	SET @TaxOTA = (SELECT SUM(gld.AmtTax )  FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))
  SET @BeforeTaxOTA = (SELECT SUM((gld.AmtBeforeTax)) FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))
  SET @AfterTaxOTA = (SELECT SUM(gld.AmtAfterTax) FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))

   SET @BalanceOTA=
    CASE 
        WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTaxOTA, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
        ELSE (ISNULL(@AfterTaxOTA, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
    END
	Begin
		insert into @TempTableGust
	 
			SELECT 1,0,atr.TransactionDateTime AS TransactionDate, 
					--aat.AccountType as Particulars, 	
					--atr.Remarks as Particulars,
					CONCAT(atr.Remarks, ' (Exchange Rate: ', atr.ExchangeRate, ')')  as Particulars,
					att.TransactionType as TransactionType,
					TransactionID as VoucherNo, 
					0 as Debit, 
					atr.Amount as Credit,
					-atr.Amount
					FROM [account].[Transaction] atr
					Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
					inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
					WHERE atr.ReservationID=@ReservationNo
			UNION
				SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
				gld.remarks as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.AmtBeforeTax as Debit,			
				0 as Credit,
				gld.AmtBeforeTax
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 )
			union 
				SELECT 3, gld.LedgerId,gld.TransDate AS TransactionDate, 
				case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
				0 as Credit,
				(gld.AmtAfterTax-gld.AmtBeforeTax)
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
				and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 )
			union
				SELECT 4,gld.LedgerId,gld.TransDate AS TransactionDate,
				concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.AmtBeforeTax as Debit, 
				0 as Credit, 
				gld.AmtBeforeTax
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID AND
				serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0)
			union
				SELECT 5,gld.LedgerId,gld.TransDate AS TransactionDate, 
				case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName +', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.AmtTax as Debit, 
				0 as Credit, 
				--gld.AmtBeforeTax 
				gld.AmtTax
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID  and
				serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0)
	End
	if (@TAXEXCEMPTION is not null)
	begin
		insert into @TempTableGust	
		SELECT 6,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,'Tax Exempted' TransactionType,
			0 as VoucherNo, 0 as Debit,	sum(AmtTax) as Credit,	-sum(AmtTax) 
			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
	
	IF	@DISCOUNTAMOUNT>0
	begin
		insert into @TempTableGust	
		values
		(7,@ReservationNo,@ENDDATE, 'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',	'Additional Discount',
		0, 	0,				@DISCOUNTAMOUNT ,	-@DISCOUNTAMOUNT )	
	end	
	--------------------------------------------Addede by sravani ----------------------------------------------
	--Begin

		insert into @TempTableOTA	 
		
			SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
			gld.remarks as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtBeforeTax as Debit,			
			0 as Credit,
			gld.AmtBeforeTax
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 )
		union 
			SELECT 3, gld.LedgerId,gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
			0 as Credit,
			(gld.AmtAfterTax-gld.AmtBeforeTax)
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 )
		union
			SELECT 4,gld.LedgerId,gld.TransDate AS TransactionDate,
			concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtBeforeTax as Debit, 
			0 as Credit, 
			gld.AmtBeforeTax
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0)
		union
			SELECT 5,gld.LedgerId,gld.TransDate AS TransactionDate, 
		    case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName +', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtTax as Debit, 
			0 as Credit, 
			--gld.AmtBeforeTax 
			gld.AmtTax
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0)
	--End
	if (@TAXEXCEMPTION is not null)
	begin
		insert into @TempTableOTA	
		SELECT 6,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,			'Tax Exempted' TransactionType,
			0 as VoucherNo, 			0 as Debit,				sum(AmtTax) as Credit,
			-sum(AmtTax) 			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
	
	IF	@DISCOUNTAMOUNT>0
	begin
	insert into @TempTableOTA	
	values
	(7,@ReservationNo,@ENDDATE, 	'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',
	'Additional Discount',	0, 	0,				@DISCOUNTAMOUNT ,	-@DISCOUNTAMOUNT )
	
	end	
	--select * from @TempTable1

	--------------------------------------------------------------Added by sravani-------------------------------------------------	
	select *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTableGust order by TransactionDate,ReservationId,DSeq --1

	--	select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from [account].[GuestLedgerDetailsTemp] order by TransactionDate,DSeq --1

		SELECT ISNULL(@BOOKEDBY, NULL) as BookedBy, 
		ISNULL(@CHECKEDINBY, NULL) as CheckedInBy, 
		ISNULL(@CHECKEDOUTBY, NULL) as CheckedOutBy,
		ISNULL(@ApprovedBy, NULL) as ApprovedBy, 
		ISNULL(@PAIDCURRENCY, NULL) as PaidCurrency,	
		ISNULL(@TOTALNIGHTS, NULL) as TotalNights,
		ISNULL(@RATEEURO, NULL) as RateEuro,
		ISNULL(@RATESRD, NULL) as RateSRD,
		ISNULL(@PAIDTYPE, NULL) as PaidType,
		ISNULL(@REFUNDAMT, NULL) as RefundAmt,
		ISNULL(@OCCUPANCY,NULL)as Occupancy,
		ISNULL(@GUESTNOTES,NULL)as GuestNotes,
		ISNULL(@REMARKS,NULL)as Remarks,
		ISNULL(@PAYMENTTERMS, NULL) AS PaymentTerm,
		ISNULL(@TAXEXCEMPTION, NULL) AS TaxExcemption,
		ISNULL(@BeforeTaxGuest, NULL) AS BeforeTax,
		ISNULL(@AfterTaxGuest, NULL) AS AfterTax,
		ISNULL(@TaxGuest, NULL) AS Tax,
		ISNULL(@BeforeTaxOTA, NULL) AS BeforeTaxOTA,
		ISNULL(@AfterTaxOTA, NULL) AS AfterTaxOTA,
		ISNULL(@TaxOTA, NULL) AS TaxOTA,
		ISNULL(@BalanceOTA, 0) AS BalanceOTA,
		ISNULL(@BASERATE, NULL) AS BaseRate,
		ISNULL(@DISCOUNTAMOUNT, 0) AS DiscountAmount,
		ISNULL(@DISCOUNTPERCENTAGE, 0) AS DiscountPercentage,
		ISNULL(@BalanceGuest, 0) AS Balance,
		ISNULL(@RoomNo,0) AS RoomNos,
		ISNULL(@FolioNo, NULL) as FolioNo,
		ISNULL(@reservationId, NULL) as ReservationID,
		  CASE
          WHEN @INVOICENO IS NULL THEN 'N/A'
          ELSE CAST(@INVOICENO AS NVARCHAR(10))
         END AS InvoiceNo
	     ,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		-------------------------------------------------------------Added By Rajendra
		,ISNULL(@ExpectedCheckIn,NULL) As ExpectedCheckIn
		,ISNULL(@ExpectedCheckOut,NULL) As ExpectedCheckOUT
		,ISNULL(@GuestName,NULL) As GuestName
		,ISNULL(@ExpectedCheckInTime,NULL) As ExpectedCheckInTime
		,ISNULL(@ExpectedCheckOutTime,NULL) As ExpectedCheckOutTime
		,ISNULL(@ReservationType,NULL) AS ReservationType
		,ISNULL(@ProfomaInvoice,0) AS ProfomaInvoice
		,ISNULL(@BillTo,NULL) AS BillTo
		,ISNULL(@SALETYPE,'N/A') AS SalesType 
		--------------------------------------------------------------Added By Rajendra
	select *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTableOTA order by TransactionDate,ReservationId,DSeq --1
END 
ELSE
BEGIN  --  New Query
set @REFUNDAMT=(select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId)
	 SET @BASERATE=(SELECT TOP 1 UnitPriceBeforeDiscount from reservation.ReservationDetails where ReservationID=@ReservationId)
   

 SELECT @DISCOUNTPERCENTAGE=AdditionalDiscount,@ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationId

 set @DISCOUNTAMOUNT=(SELECT sum(Discount)   FROM account.GuestLedgerDetails WHERE FolioNo=@FolioNo)

  SET @TaxGuest = (SELECT SUM(gld.AmtTax ) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ) );
  SET @BeforeTaxGuest = (SELECT SUM((gld.AmtBeforeTax)) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ));
  SET @AfterTaxGuest = (SELECT SUM(gld.AmtAfterTax) FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 ));

   SET @BalanceGuest=
    CASE 
        WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTaxGuest, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
        ELSE (ISNULL(@AfterTaxGuest, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
    END

	SET @TaxOTA = (SELECT SUM(gld.AmtTax )  FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))
  SET @BeforeTaxOTA = (SELECT SUM((gld.AmtBeforeTax)) FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))
  SET @AfterTaxOTA = (SELECT SUM(gld.AmtAfterTax) FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 ))

   SET @BalanceOTA=
    CASE 
        WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTaxOTA, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
        ELSE (ISNULL(@AfterTaxOTA, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0))
    END
	Begin
		insert into @TempTableGust
	 
			SELECT 1,0,atr.TransactionDateTime AS TransactionDate, 
					--aat.AccountType as Particulars, 	
					--atr.Remarks as Particulars,
					CONCAT(atr.Remarks, ' (Exchange Rate: ', atr.ExchangeRate, ')')  as Particulars,
					att.TransactionType as TransactionType,
					TransactionID as VoucherNo, 
					0 as Debit, 
					atr.Amount as Credit,
					-atr.Amount
					FROM [account].[Transaction] atr
					Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
					inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
					WHERE atr.ReservationID=@ReservationNo
			UNION
-- Room Charge
				SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
				gld.remarks as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.UnitPriceBeforeDiscount as Debit,			
				0 as Credit,
				gld.UnitPriceBeforeDiscount
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 )
			union 

			SELECT 3,gld.LedgerId,gld.TransDate AS TransactionDate, 
				gld.remarks as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				0 as Debit,			
				gld.Discount as Credit,
				-gld.Discount
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo  
				and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 )

			union
-- Room Charge Vat
				SELECT 4, gld.LedgerId,gld.TransDate AS TransactionDate, 
				case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
				0 as Credit,
				(gld.AmtAfterTax-gld.AmtBeforeTax)
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
				and serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0 )
			union
-- Service Charge
				SELECT 5,gld.LedgerId,gld.TransDate AS TransactionDate,
				concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.AmtBeforeTax as Debit, 
				0 as Credit, 
				gld.AmtBeforeTax
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID AND
				serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0)
			union
-- Service Charge Vat
				SELECT 6,gld.LedgerId,gld.TransDate AS TransactionDate, 
				case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName +', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
				st.ServiceName TransactionType,
				gld.TransRefNo as VoucherNo, 
				gld.AmtTax as Debit, 
				0 as Credit, 
				--gld.AmtBeforeTax 
				gld.AmtTax
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID  and
				serviceid in 
				(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @GuestId and ServicePercent>0)
	End
	if (@TAXEXCEMPTION is not null)
	begin
		insert into @TempTableGust	
		SELECT 7,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,'Tax Exempted' TransactionType,
			0 as VoucherNo, 0 as Debit,	sum(AmtTax) as Credit,	-sum(AmtTax) 
			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
	
	--IF	@DISCOUNTAMOUNT>0
	--begin
	--	insert into @TempTableGust	
	--	values
	--	(8,@ReservationNo,@ENDDATE, 'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',	'Additional Discount',
	--	0, 	0,				@DISCOUNTAMOUNT ,	-@DISCOUNTAMOUNT )	
	--end	
	--------------------------------------------Addede by sravani ----------------------------------------------
	--Begin

		insert into @TempTableOTA	 
-- Room Charge Booking	
			SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
			gld.remarks as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.UnitPriceBeforeDiscount as Debit,			
			0 as Credit,
			gld.UnitPriceBeforeDiscount
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 )
		union 

-- Discount
			SELECT 3,gld.LedgerId,gld.TransDate AS TransactionDate, 
			gld.remarks + ',Discount '+ CONVERT(nvarchar(100), gld.DiscountPercentage)+'%' as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			0 as Debit,			
			gld.Discount as Credit,
			-gld.Discount
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  
			and st.ServiceTypeID=@SERVICETYPEID	and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 )
		
		union
-- Room Charge VAT
			SELECT 4, gld.LedgerId,gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
			0 as Credit,
			(gld.AmtAfterTax-gld.AmtBeforeTax)
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0 )
		union
-- Service Charge
			SELECT 5,gld.LedgerId,gld.TransDate AS TransactionDate,
			concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtBeforeTax as Debit, 
			0 as Credit, 
			gld.AmtBeforeTax
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0)
		union
-- Service Charge VAT
			SELECT 6,gld.LedgerId,gld.TransDate AS TransactionDate, 
		    case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName +', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtTax as Debit, 
			0 as Credit, 
			--gld.AmtBeforeTax 
			gld.AmtTax
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
			and serviceid in 
			(select serviceid FROM [HMSYOGH].[guest].[OTAServices] where ReservationID=@ReservationNo and GuestID_CompanyID= @OTAId and ServicePercent>0)
	--End
	if (@TAXEXCEMPTION is not null)
	begin
		insert into @TempTableOTA	
		SELECT 7,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,			'Tax Exempted' TransactionType,
			0 as VoucherNo, 			0 as Debit,				sum(AmtTax) as Credit,
			-sum(AmtTax) 			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
	
	--IF	@DISCOUNTAMOUNT>0
	--begin
	--insert into @TempTableOTA	
	--values
	--(7,@ReservationNo,@ENDDATE, 	'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',
	--'Additional Discount',	0, 	0,				@DISCOUNTAMOUNT ,	-@DISCOUNTAMOUNT )
	
	--end	
	 

	--------------------------------------------------------------Added by sravani-------------------------------------------------	
	select *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTableGust order by TransactionDate,ReservationId,DSeq --1

	--	select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from [account].[GuestLedgerDetailsTemp] order by TransactionDate,DSeq --1

		SELECT ISNULL(@BOOKEDBY, NULL) as BookedBy, 
		ISNULL(@CHECKEDINBY, NULL) as CheckedInBy, 
		ISNULL(@CHECKEDOUTBY, NULL) as CheckedOutBy,
		ISNULL(@ApprovedBy, NULL) as ApprovedBy, 
		ISNULL(@PAIDCURRENCY, NULL) as PaidCurrency,	
		ISNULL(@TOTALNIGHTS, NULL) as TotalNights,
		ISNULL(@RATEEURO, NULL) as RateEuro,
		ISNULL(@RATESRD, NULL) as RateSRD,
		ISNULL(@PAIDTYPE, NULL) as PaidType,
		ISNULL(@REFUNDAMT, NULL) as RefundAmt,
		ISNULL(@OCCUPANCY,NULL)as Occupancy,
		ISNULL(@GUESTNOTES,NULL)as GuestNotes,
		ISNULL(@REMARKS,NULL)as Remarks,
		ISNULL(@PAYMENTTERMS, NULL) AS PaymentTerm,
		ISNULL(@TAXEXCEMPTION, NULL) AS TaxExcemption,
		ISNULL(@BeforeTaxGuest, NULL) AS BeforeTax,
		ISNULL(@AfterTaxGuest, NULL) AS AfterTax,
		ISNULL(@TaxGuest, NULL) AS Tax,
		ISNULL(@BeforeTaxOTA, NULL) AS BeforeTaxOTA,
		ISNULL(@AfterTaxOTA, NULL) AS AfterTaxOTA,
		ISNULL(@TaxOTA, NULL) AS TaxOTA,
		ISNULL(@BalanceOTA, 0) AS BalanceOTA,
		ISNULL(@BASERATE, NULL) AS BaseRate,
		ISNULL(@DISCOUNTAMOUNT, 0) AS DiscountAmount,
		ISNULL(@DISCOUNTPERCENTAGE, 0) AS DiscountPercentage,
		ISNULL(@BalanceGuest, 0) AS Balance,
		ISNULL(@RoomNo,0) AS RoomNos,
		ISNULL(@FolioNo, NULL) as FolioNo,
		ISNULL(@reservationId, NULL) as ReservationID,
		  CASE
          WHEN @INVOICENO IS NULL THEN 'N/A'
          ELSE CAST(@INVOICENO AS NVARCHAR(10))
         END AS InvoiceNo
	     ,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		-------------------------------------------------------------Added By Rajendra
		,ISNULL(@ExpectedCheckIn,NULL) As ExpectedCheckIn
		,ISNULL(@ExpectedCheckOut,NULL) As ExpectedCheckOUT
		,ISNULL(@GuestName,NULL) As GuestName
		,ISNULL(@ExpectedCheckInTime,NULL) As ExpectedCheckInTime
		,ISNULL(@ExpectedCheckOutTime,NULL) As ExpectedCheckOutTime
		,ISNULL(@ReservationType,NULL) AS ReservationType
		,ISNULL(@ProfomaInvoice,0) AS ProfomaInvoice
		,ISNULL(@BillTo,NULL) AS BillTo
		,ISNULL(@SALETYPE,'N/A') AS SalesType 
		--------------------------------------------------------------Added By Rajendra
	select *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTableOTA order by TransactionDate,ReservationId,DSeq --1

END



END
