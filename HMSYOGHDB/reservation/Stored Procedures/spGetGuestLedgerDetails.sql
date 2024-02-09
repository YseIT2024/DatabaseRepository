
CREATE PROCEDURE [reservation].[spGetGuestLedgerDetails] --10798,1,1,3
(	
    @FolioNo int null,	
	@LocationID int,
	@DrawerID int=null,
	@UserId int,
	@GuestOrCompanyId int=0,
	@GuestOrCompanyTypeId int=0
)
AS
Begin
SET NOCOUNT ON;
  
	DECLARE @ReservationNo int=0;
	Declare @reservationId int;
    set @reservationId= (Select ReservationID from reservation.Reservation where FolioNumber=@FolioNo)
    DECLARE @BOOKEDBY nvarchar(100);
	DECLARE @CHECKEDINBY nvarchar(100);
	DECLARE @CHECKEDOUTBY nvarchar(100);
	DECLARE @ApprovedBy nvarchar(100);
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
	DECLARE @BeforeTax DECIMAL (18,4);
	DECLARE @AfterTax DECIMAL (18,4);
	DECLARE @Tax DECIMAL (18,4);
	DECLARE @Balance DECIMAL(18,4);

	DECLARE @DISCOUNTPERCENTAGE decimal(18,2);
	DECLARE @DISCOUNTAMOUNT decimal(18,2);
	DECLARE @ENDDATE DATE;

	DECLARE @CONFIRMEDDATE DATETIME;
	DECLARE @ROOMTYPEPE nvarchar(250);

	DECLARE @Adult int;
    DECLARE @Child Int;
	DECLARE @COMPLEMENTARYAMOUNT decimal(18,2);

	SET @ROOMTYPEPE = (select [reservation].[fnGetRoomCategory](@ReservationId))
	SET @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationId)
	DECLARE @SALETYPE nvarchar(250);

	--select * from reservation.ReservationMode
	select  @RESERVATIONMODE=ReservationModeID from  reservation.Reservation where FolioNumber=@FolioNo
	set @BOOKEDBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.ReservationID=@reservationId And RI.ReservationStatusID=1)
					
   SET @OCCUPANCY = (SELECT Adults + Children FROM reservation.Reservation WHERE ReservationID = @reservationId);	

   SET @Adult =(SELECT SUM(CASE WHEN DATEDIFF(YEAR, DOB, GETDATE()) >= 18 THEN 1 ELSE 0 END) AS AdultCount FROM reservation.ReservationGuestMates WHERE ReservationID = @reservationId);
   SET @Child = (SELECT SUM(CASE WHEN DATEDIFF(YEAR, DOB, GETDATE()) < 18 THEN 1 ELSE 0 END) AS ChildCount FROM reservation.ReservationGuestMates WHERE ReservationID = @reservationId);

   SET @GUESTNOTES=(select Note from [reservation].[Note] where ReservationID=@reservationId and NoteTypeID=3)
   SET @REMARKS=(select Note from [reservation].[Note] where ReservationID=@reservationId and NoteTypeID=4)
   --SET @PAYMENTTERMS = (SELECT CONCAT(CAST(GC.CreditPeriod AS NVARCHAR(100)), ' Days Credit, @', CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) , '% After Credit') FROM [guest].[GuestCompany] GC
                        --INNER JOIN [reservation].[Reservation] RR ON GC.CompanyID = RR.CompanyTypeID WHERE RR.ReservationID = @reservationId)
   
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
	
	SET @SALETYPE =(SELECT rs.SalesType FROM [HMSYOGH].[reservation].[SalesTypes] rs
	INNER join reservation.Reservation rr on rs.SalesTypeID=rr.SalesTypeID 
	where rr.ReservationID=@reservationId)
 
 
  -- SET @TAXEXCEMPTION = (SELECT TaxRefNo from [reservation].[TaxExemptionDetails] TE
  --                       INNER JOIN [reservation].[Reservation] RR ON TE.ReservationID=RR.ReservationID WHERE RR.ReservationID= 7606 )
   
   SET @TAXEXCEMPTION = (SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@reservationId)

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
 set @REFUNDAMT=(select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId)
  
 SET @BASERATE=(SELECT TOP 1 UnitPriceBeforeDiscount from reservation.ReservationDetails where ReservationID=@ReservationId)
  
 select @ReservationNo=reservationid  from reservation.Reservation where FolioNumber=@FolioNo 
 Declare @RoomNo varchar(250) =(select [reservation].[fnGetReserveredRoom] (@ReservationNo))

 declare @TempTable Table(ID INT IDENTITY(1, 1),DSeq int,ReservationId int,TransactionDate datetime,Particulars varchar(500),TransactionType varchar(50),VoucherNo int,Debit decimal(18,2),Credit decimal(18,2),TotalB decimal(18,2))
  

DECLARE @NewQueryReservationId int =6580
	DECLARE @IsNewQuery int=0;
		
	IF((select ReservationID from reservation.Reservation where FolioNumber=@FolioNo) > @NewQueryReservationId)
	BEGIN
		SET @IsNewQuery=1;
	END

	IF(@IsNewQuery=0)
		BEGIN   --- Old Query

			SET @COMPLEMENTARYAMOUNT = (select sum(AmtAfterTax * (isnull(ComplimentaryPercentage,0) /100))
			FROM [account].[GuestLedgerDetails] 
			WHERE FolioNo=@FolioNo )

			SELECT @DISCOUNTAMOUNT=AdditionalDiscountAmount,@DISCOUNTPERCENTAGE=AdditionalDiscount,@ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationId
			--set @Tax=(select sum(AmtTax) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
			--SET @Tax =(SELECT sum(AmtTax+ (AmtTax * (isnull(ComplimentaryPercentage,0)/100))) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo) --and ComplimentaryPercentage<100)
			--SET @Tax =(SELECT SUM((AmtAfterTax - (AmtAfterTax  *ISNULL(ComplimentaryPercentage, 0) / 100))*  0.1) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
			
			SET @Tax =(SELECT sum(AmtTax- (AmtTax * (isnull(ComplimentaryPercentage,0)/100))) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo) --and ComplimentaryPercentage<100)
			
			set @BeforeTax=(select sum(AmtBeforeTax) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
			set @AfterTax=(select sum(AmtAfterTax) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
			SET @Balance = 
			CASE 
			WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTax, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0) - ISNULL(@COMPLEMENTARYAMOUNT,0))
			ELSE (ISNULL(@BeforeTax, 0)+ISNULL(@Tax, 0)  - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0) - ISNULL(@COMPLEMENTARYAMOUNT,0))
			END

 if(@ReservationNo<538)
 Begin

-- delete  from [account].[GuestLedgerDetailsTemp] 
 insert into @TempTable
--  insert into [account].[GuestLedgerDetailsTemp]
	  SELECT 1,gld.LedgerId,gld.TransDate AS TransactionDate, 
			--st.ServiceName as Particulars,
			gld.remarks as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			--gld.AmtAfterTax as Debit, 
			gld.AmtBeforeTax as Debit, 
			0 as Credit ,
			gld.AmtBeforeTax-0
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo 
		UNION 
			SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
			0 as Credit, 
			(gld.AmtAfterTax-gld.AmtBeforeTax)
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   -- and st.ServiceTypeID=@SERVICETYPEID 
	  UNION
	  SELECT 0,0,atr.TransactionDateTime AS TransactionDate, 
			--aat.AccountType as Particulars, 	
			atr.Remarks as Particulars,
			att.TransactionType as TransactionType,
			TransactionID as VoucherNo, 
			0 as Debit, 
			atr.Amount as Credit, 
			-atr.Amount
			FROM [account].[Transaction] atr
			Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
			inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
			WHERE atr.ReservationID=@ReservationNo	
			union
			SELECT 3,@ReservationNo,getdate() AS TransactionDate, 
			'Tax Exempted'  as Particulars,
			'Tax Exempted' TransactionType,
			0 as VoucherNo, 
			0 as Debit,			
			sum(AmtAfterTax)-sum(AmtBeforeTax) as Credit,
			-sum(AmtTax) 
			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
			
			
			
End
Else
Begin
insert into @TempTable
--insert into [account].[GuestLedgerDetailsTemp]
	 
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
		WHERE atr.ReservationID=@ReservationNo --and atr.GuestCompanyId=@GuestOrCompanyId and atr.GuestCompanyTypeId=@GuestOrCompanyTypeId
-- Room Charge
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
		WHERE gld.FolioNo=@FolioNo  and st.ServiceTypeID=@SERVICETYPEID


--3. Room Charge COMPLEMENTARY
		union
		SELECT	3,gld.LedgerId,gld.TransDate  as TransDate,
		Remarks +' Reversed Complimentary ('+convert(nvarchar(100), isnull(gld.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		0 as Debit,	
		((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax) as Credit,
		--((isnull(gld.ComplimentaryPercentage,0)* AmtAfterTax)/100) as Credit,
		-((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)
		---((isnull(gld.ComplimentaryPercentage,0)* AmtAfterTax)/100)
		FROM [account].[GuestLedgerDetails] gld  
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo AND  gld.ServiceId=@SERVICETYPEID AND IsComplimentary=1

-- Room Charge VAT
		union 
		SELECT 4, gld.LedgerId,gld.TransDate AS TransactionDate, 
		case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		--(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit,
		CASE WHEN gld.IsComplimentary = 1 THEN ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE AmtTax END  as Debit,
		0 as Credit,
		--(gld.AmtAfterTax-gld.AmtBeforeTax)
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE AmtTax END
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
		and CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  AmtTax END > 0
-- Service Charge
		union
		SELECT 5,gld.LedgerId,gld.TransDate AS TransactionDate, 
		--case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
		concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		gld.AmtBeforeTax as Debit, 
		0 as Credit, 
		gld.AmtBeforeTax
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 


-- Service Charge Complimentary
		union
		SELECT 6,gld.LedgerId,gld.TransDate  as TransDate,
		concat(st.ServiceName,' - ',gld.Remarks,+' Reversed Complimentary (',CONVERT(nvarchar(50),isnull(gld.ComplimentaryPercentage,0)),'%)') as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		0 as Debit,
		--((isnull(gld.ComplimentaryPercentage,0)* gld.AmtAfterTax)/100) as Credit,
		---((isnull(gld.ComplimentaryPercentage,0)* gld.AmtAfterTax)/100)
		((isnull(gld.ComplimentaryPercentage,0) / 100)* gld.AmtBeforeTax) as Credit,
		-((isnull(gld.ComplimentaryPercentage,0) / 100)* gld.AmtBeforeTax)

		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID  and IsComplimentary=1
-- Service Charge VAT
		union
		SELECT 7,gld.LedgerId,gld.TransDate AS TransactionDate, 
		--case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
		case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName+' - '+gld.Remarks+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		--gld.AmtTax as Debit, 
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  AmtTax END  Debit,
		0 as Credit, 
		--gld.AmtTax
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  AmtTax END
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
		and CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  AmtTax END  > 0
		
End
	if (@TAXEXCEMPTION is not null)
	begin
	insert into @TempTable	
	SELECT 6,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,
			'Tax Exempted' TransactionType,
			0 as VoucherNo, 
			0 as Debit,			
			sum(AmtTax) as Credit,
			-sum(AmtTax) 
			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
	
	IF	@DISCOUNTAMOUNT>0
	begin
	insert into @TempTable	
	values
	(7,@ReservationNo,@ENDDATE, 
	'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',
	'Additional Discount',
	0, 
	0,			
	@DISCOUNTAMOUNT ,
	-@DISCOUNTAMOUNT )
	
	end	
			
	select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTable order by TransactionDate,ReservationId,DSeq --1
	
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
		ISNULL(@BeforeTax, NULL) AS BeforeTax,
		--ISNULL(@AfterTax , NULL) AS AfterTax,
		ISNULL(@BeforeTax+@Tax, NULL) AS AfterTax,
		ISNULL(@Tax, NULL) AS Tax,
		ISNULL(@BASERATE, NULL) AS BaseRate,
		ISNULL(@DISCOUNTAMOUNT, 0) AS DiscountAmount,
		ISNULL(@DISCOUNTPERCENTAGE, 0) AS DiscountPercentage,
		ISNULL(@Balance - @COMPLEMENTARYAMOUNT, 0) AS Balance,
		ISNULL(@Adult,0)AS AdultCount,
		ISNULL(@Child,0)AS ChildCount,
		--ISNULL(@INVOICENO, NULL) as InvoiceNo
		  CASE
          WHEN @INVOICENO IS NULL THEN 'N/A'
          ELSE CAST(@INVOICENO AS NVARCHAR(10))
         END AS InvoiceNo
	     ,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,ISNULL(@COMPLEMENTARYAMOUNT,0)AS ComplementaryAmount
		,ISNULL(@SALETYPE,'N/A') AS SalesType 

END

ELSE -- New Query Start
BEGIN    


		SET @COMPLEMENTARYAMOUNT = (select sum(AmtAfterTax * (isnull(ComplimentaryPercentage,0) /100))---replaced beforetax to aftertax
									FROM [account].[GuestLedgerDetails] 
									WHERE FolioNo=@FolioNo )

	SELECT @ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationId
	SELECT @DISCOUNTAMOUNT=sum(Discount) FROM account.GuestLedgerDetails where FolioNo=@FolioNo
   
  SET @Tax =(SELECT sum(AmtTax+ (AmtTax * (isnull(ComplimentaryPercentage,0)/100))) from [account].[GuestLedgerDetails] where FolioNo=@FolioNo) --and ComplimentaryPercentage<100)
  set @BeforeTax=(select sum(case when ServiceId=18 then UnitPriceBeforeDiscount else AmtBeforeTax end)  from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
  set @AfterTax=@BeforeTax-@DISCOUNTAMOUNT +@Tax; --(select sum(AmtAfterTax)  from [account].[GuestLedgerDetails] where FolioNo=@FolioNo)
  SET @Balance = 
    CASE 
        WHEN @TAXEXCEMPTION IS NOT NULL THEN (ISNULL(@BeforeTax, 0) - ISNULL(@DISCOUNTAMOUNT, 0) - ISNULL(@REFUNDAMT, 0) - ISNULL(@COMPLEMENTARYAMOUNT,0))
        ELSE (ISNULL(@AfterTax, 0) - ISNULL(@REFUNDAMT, 0) - ISNULL(@COMPLEMENTARYAMOUNT,0))
    END


insert into @TempTable
--insert into [account].[GuestLedgerDetailsTemp]
	 
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
		WHERE atr.ReservationID=@ReservationNo and atr.GuestComanyId=@GuestOrCompanyId and atr.GuestCompanyTypeId=@GuestOrCompanyTypeId
-- Room Charge
		UNION
		SELECT 2,gld.LedgerId,gld.TransDate AS TransactionDate, 
		gld.remarks as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		gld.UnitPriceBeforeDiscount as Debit,			
		0 as Credit,
		gld.UnitPriceBeforeDiscount
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo  and st.ServiceTypeID=@SERVICETYPEID
		union
-- Discount Calculation		
	SELECT 3,gld.LedgerId,gld.TransDate AS TransactionDate, 
		Remarks +' Discount '+convert(nvarchar(100),gld.DiscountPercentage)+'%' as ItemDescription,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		0 as Debit,			
		gld.Discount as Credit,
		-gld.Discount
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo  and st.ServiceTypeID=@SERVICETYPEID and Discount>0

--3. Room Charge COMPLEMENTARY
		union
		SELECT	4,gld.LedgerId,gld.TransDate  as TransDate,
		Remarks +' Reversed Complimentary ('+convert(nvarchar(100), isnull(gld.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		0 as Debit,	
		((isnull(gld.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount) as Credit,
		--((isnull(gld.ComplimentaryPercentage,0)* UnitPriceBeforeDiscount)/100) as Credit,
		-((isnull(gld.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount)
		---((isnull(gld.ComplimentaryPercentage,0)* UnitPriceBeforeDiscount)/100)
		FROM [account].[GuestLedgerDetails] gld  
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo AND  gld.ServiceId=@SERVICETYPEID AND IsComplimentary=1

-- Room Charge VAT
		union 
		SELECT 5, gld.LedgerId,gld.TransDate AS TransactionDate, 
		case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%'  else st.ServiceName End as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		--(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit,
		CASE WHEN gld.IsComplimentary = 1 THEN ((gld.TaxPer / 100)*(UnitPriceBeforeDiscount - ((isnull(gld.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount)))
		ELSE --((gld.TaxPer*AmtAfterTax)/100) 
		AmtTax
		END  as Debit,
		0 as Credit,
		--(gld.AmtAfterTax-gld.AmtBeforeTax)
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(UnitPriceBeforeDiscount - ((isnull(gld.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount)))
		ELSE 
		--((gld.TaxPer*AmtAfterTax)/100)
		AmtTax
		END
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo and st.ServiceTypeID=@SERVICETYPEID 
		and CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(UnitPriceBeforeDiscount - ((isnull(gld.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount)))
		ELSE AmtTax END > 0
-- Service Charge
		union
		SELECT 6,gld.LedgerId,gld.TransDate AS TransactionDate, 
		--case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
		concat(st.ServiceName,' - ',gld.Remarks) as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		gld.AmtBeforeTax as Debit, 
		0 as Credit, 
		gld.AmtBeforeTax
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 


-- Service Charge Complimentary
		union
		SELECT 7,gld.LedgerId,gld.TransDate  as TransDate,
		concat(st.ServiceName,' - ',gld.Remarks,+' Reversed Complimentary (',CONVERT(nvarchar(50),isnull(gld.ComplimentaryPercentage,0)),'%)') as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		0 as Debit,
		((isnull(gld.ComplimentaryPercentage,0)* gld.AmtAfterTax)/100) as Credit,
		-((isnull(gld.ComplimentaryPercentage,0)* gld.AmtAfterTax)/100)
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID  and IsComplimentary=1
-- Service Charge VAT
		union
		SELECT 8,gld.LedgerId,gld.TransDate AS TransactionDate, 
		--case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
		case when st.ServiceTypeID=@SERVICETYPEID then st.ServiceName +' ' + isnull(convert(varchar(10),46),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName+' - '+gld.Remarks+', VAT ' + CONVERT(VARCHAR(10), gld.Taxper) + '%' End as Particulars,
		st.ServiceName TransactionType,
		gld.TransRefNo as VoucherNo, 
		--gld.AmtTax as Debit, 
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  AmtTax END  Debit,
		0 as Credit, 
		--gld.AmtTax
		CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE AmtTax END
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>@SERVICETYPEID 
		and CASE WHEN gld.IsComplimentary = 1 THEN  ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE AmtTax END  > 0
		

	if (@TAXEXCEMPTION is not null)
	begin
	insert into @TempTable	
	SELECT 9,@ReservationNo,@ENDDATE AS TransactionDate, 
			'Tax Exempted Ref:' + @TAXEXCEMPTION  as Particulars,
			'Tax Exempted' TransactionType,
			0 as VoucherNo, 
			0 as Debit,			
			sum(AmtTax) as Credit,
			-sum(AmtTax) 
			FROM [account].[GuestLedgerDetails] where foliono=@FolioNo
	end	
 
			
	select  *,SUM(TotalB) OVER (ORDER BY TransactionDate,ReservationId,DSeq) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTable order by TransactionDate,ReservationId,DSeq --1
	
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
		ISNULL(@BeforeTax, NULL) AS BeforeTax,
		--ISNULL(@AfterTax , NULL) AS AfterTax,
		ISNULL(@AfterTax, NULL) AS AfterTax,
		ISNULL(@Tax, NULL) AS Tax,
		ISNULL(@BASERATE, NULL) AS BaseRate,
		ISNULL(@DISCOUNTAMOUNT, 0) AS DiscountAmount,
		ISNULL(@DISCOUNTPERCENTAGE, 0) AS DiscountPercentage,
		ISNULL(@Balance, 0) AS Balance,
		ISNULL(@Adult,0)AS AdultCount,
		ISNULL(@Child,0)AS ChildCount,
		--ISNULL(@INVOICENO, NULL) as InvoiceNo
		  CASE
          WHEN @INVOICENO IS NULL THEN 'N/A'
          ELSE CAST(@INVOICENO AS NVARCHAR(10))
         END AS InvoiceNo
	     ,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,ISNULL(@COMPLEMENTARYAMOUNT,0)AS ComplementaryAmount
		,ISNULL(@SALETYPE,'N/A') AS SalesType 

END

END
 