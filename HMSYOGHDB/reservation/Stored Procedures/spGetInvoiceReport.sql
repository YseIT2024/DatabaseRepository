
CREATE PROCEDURE [reservation].[spGetInvoiceReport]
(
	@ReservationId int,
	@UserId int,
	@DocTypeId int=2
)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 DECLARE @RateEURO_USD nvarchar(250)=1;
	DECLARE @ExchangeRateUSD_SRD nvarchar(250);
	DECLARE @ExchangeRateEURO_SRD nvarchar(250);
	DECLARE @TAXPERCENTAGE nvarchar(250);
	DECLARE @CREATEDBY nvarchar(100);
	DECLARE @PAIDCURRENCY nvarchar(250);
	DECLARE @PAIDTYPE nvarchar(250);
	DECLARE @TOTALNIGHTS nvarchar(250);
	DECLARE @FOLIONUMBER INT;
	DECLARE @SERVICETYPEID INT=18;
	DECLARE @PAYMENTTERMS nvarchar(250);


	DECLARE @TAXEXCEMPTION nvarchar(250);
	DECLARE @DISCOUNTPERCENTAGE decimal(18,2);
	DECLARE @DISCOUNTAMOUNT decimal(18,2);
	DECLARE @VatAmount DECIMAL(18,2);
	DECLARE @RoomNo varchar(250);
	DECLARE @ENDDATE DATE;

	DECLARE @CONFIRMEDDATE DATETIME;
	DECLARE @ROOMTYPEPE nvarchar(250);
	--DECLARE @TAXEXCEMPTION nvarchar(250);
	DECLARE @ISCOMPLEMENTARY INT;
	DECLARE @COMPLEMENTARYAMOUNT decimal(18,2)=0;
	DECLARE @TotalAmountBeforeTax DECIMAL(18,2);
	DECLARE @TotalAmountAfterTax DECIMAL(18,2);

	SET @ROOMTYPEPE = (select [reservation].[fnGetRoomCategory](@ReservationId))
	SET @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationId)


		----set @CREATEDBY=(Select top(1)CD.FirstName from  app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID where au.UserID=@UserId)
		Select top(1) @CREATEDBY=CONCAT(CD.FirstName ,' ',CD.LastName ,' (', r.[Role],')') from  app.[User] au
		inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
		inner join app.UsersAndRoles ur on ur.UserID = au.UserID
		inner join app.Roles r on ur.RoleID=r.RoleId
		where au.UserID=
		(Select  CreatedBy  from  [reservation].[CheckOutDetail] where ReservationID=@ReservationId)
		

		SELECT @PAIDCURRENCY= [reservation].[fnGetPaidCurrency] (@reservationId)
		SELECT @ExchangeRateUSD_SRD= CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate]))  FROM  [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT(AccountingDate,'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=2
		SELECT @ExchangeRateEURO_SRD=  CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate]))  FROM [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT([AccountingDate],'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=3
		SELECT @TOTALNIGHTS= NIGHTS FROM reservation.Reservation where RESERVATIONID=@reservationId
		SELECT @PAIDTYPE=[reservation].[fnGetPaidType] (@reservationId)
		SET @PAIDTYPE=ISNULL(@PAIDTYPE,'USD')

		SET @RoomNo=(select [reservation].[fnGetReserveredRoom] (@ReservationId))
		SET @TAXPERCENTAGE = (SELECT  top(1)TotalTax FROM reservation.reservationdetails where ReservationID=@ReservationId)


		SET @PAYMENTTERMS = (SELECT CONCAT(CAST(GC.CreditPeriod AS NVARCHAR(100)), ' Days Credit, @', CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) , '% After Credit') FROM [guest].[GuestCompany] GC
		INNER JOIN [reservation].[Reservation] RR ON GC.CompanyID = RR.CompanyTypeID WHERE RR.ReservationID = @reservationId)
 
		SET @FOLIONUMBER= (SELECT FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationId);

		
		 
		IF(not exists (select * from [reservation].[ProformaInvoice] where ReservationId=@ReservationId and DocumentTypeId=@DocTypeId))
			BEGIN
				DECLARE @OutputSequenceNo VARCHAR(255);
				EXEC [report].spGetReportSequenceNo @DocTypeId = @DocTypeId, @SequenceNo = @OutputSequenceNo OUTPUT;

				INSERT INTO [reservation].[ProformaInvoice](
				[DocumentTypeId]
				,[ReservationId]
				,[ProformaInvoiceNo]
				,[CreatedDate]
				,[CreatedBy])
				VALUES
				(@DocTypeId,@ReservationId,@OutputSequenceNo,GETDATE(),@UserID)
			END

			DECLARE @TempTable Table(DSeq INT,ID INT IDENTITY(1, 1),DetailsNo Int,
									TransactionDate DATE,
									ItemDescription nvarchar(max),
									AmountUSD decimal(18,2),
									BalanceUSD decimal(18,2),
									TransactionDate2 DATE)


	DECLARE @NewQueryReservationId int =6580
	DECLARE @IsNewQuery int=0;
		
	IF(@ReservationId > @NewQueryReservationId)
	BEGIN
		SET @IsNewQuery=1;
	END

	IF(@IsNewQuery=0)
		BEGIN

		---- Amount Calculation

		SET @TotalAmountBeforeTax=(SELECT sum(AmtBeforeTax) from [account].[GuestLedgerDetails] where FolioNo=@FOLIONUMBER)
		SET @VatAmount =(SELECT sum(AmtTax- (AmtTax * (isnull(ComplimentaryPercentage,0)/100))) from [account].[GuestLedgerDetails] where FolioNo=@FOLIONUMBER) --and ComplimentaryPercentage<100)
		SET @TotalAmountAfterTax=(@TotalAmountBeforeTax + @VatAmount) --(SELECT sum(AmtAfterTax) from [account].[GuestLedgerDetails] where FolioNo=@FOLIONUMBER )
		 

		SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
		SELECT 
		@DISCOUNTPERCENTAGE=AdditionalDiscount,
		@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
		@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
		FROM reservation.Reservation WHERE ReservationID=@ReservationId

		SET @DISCOUNTAMOUNT=(SELECT ((@DISCOUNTPERCENTAGE/100) * SUM(AmtBeforeTax)) FROM account.GuestLedgerDetails WHERE FolioNo=@FOLIONUMBER AND ServiceId=@SERVICETYPEID)
		 
		SET @COMPLEMENTARYAMOUNT = (select sum(AmtBeforeTax * (isnull(ComplimentaryPercentage,0) /100))
		FROM [account].[GuestLedgerDetails] 
		WHERE FolioNo=@FOLIONUMBER )

		SELECT DISTINCT
		CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
		,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
							+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
							+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
		,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
		,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
		--,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]
		--,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]
		
		,CASE WHEN RS.ActualCheckIn IS NULL THEN FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckIn,'dd-MMM-yyyy') END AS [ExpectedCheckIn]
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy') END AS [ExpectedCheckOut]
		
		,Nights as TotalDay
		,Rooms as RoomQty
		, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
		,RS.ReservationID as BookingNo
		--,(select STRING_AGG(TransactionMode, ',')  from account.TransactionMode where TransactionModeID in ( select  distinct TransactionModeID from account.[Transaction] where ReservationID=@ReservationId)) as SalesType
		,@PAIDTYPE as SalesType
		,RP.ProformaInvoiceNo
		--,FORMAT(RP.CreatedDate,'dd-MMM-yyyy') as InvoiceDate
		--,FORMAT(GETDATE(),'dd-MMM-yyyy') as InvoiceDate
		,(select FORMAT(max(TransDate) ,'dd-MMM-yyyy') from account.GuestLedgerDetails where FolioNo=@FOLIONUMBER ) as InvoiceDate
		,'' as BankName
		,@RateEURO_USD as RateEURO_USD
		,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
		,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD
		--,RS.[TotalAmountBeforeTax] + ISNULL(@TotalAmountBeforeTax,0)  as TotalAmountBeforeTax
		--,RS.TotalTaxAmount + ISNULL(@VatAmount,0) as VatAmount 
		--,RS.[TotalAmountAfterTax] + ISNULL(@TotalAmountAfterTax,0)  as TotalAmountAfterTax
		,ISNULL(@TotalAmountBeforeTax,0) as TotalAmountBeforeTax
		,ISNULL(@VatAmount,0) as VatAmount
		,ISNULL(@TotalAmountAfterTax,0) as TotalAmountAfterTax
		,@TAXPERCENTAGE as TaxPercentage
		--,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) as ReceivedAmount
		,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0) +((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=1),0))) as ReceivedAmount
		,ISNULL(@CREATEDBY,'N/A') as CreatedByName
		--,RP.CreatedDate as CreatedDate
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
		--,case when @TAXEXCEMPTION is not null then 
		--((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) ) - @VatAmount) - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT)
		--else ((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) )) - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT) end 
		--as  TotalAmountDue
		
		,case when @TAXEXCEMPTION is not null then 
		((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0) ) - @VatAmount) - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT)
		else ((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0) ))-((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=1),0))) - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT) end 
		as  TotalAmountDue


		--,(@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) )) as  TotalAmountDue
		--,((RS.[TotalAmountAfterTax] + ISNULL(@TotalAmountAfterTax,0)) -  (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) )) as  TotalAmountDue
		,'8120.3.7087 (USD)' as USD
		,'8114.0.0343 (SRD)' as SRD
		,'8130.3.3111 (EURO)' as EURO
		,@RoomNo AS RoomNo
		,CASE WHEN RS.CompanyID =1 THEN '' ELSE (
		Select
		(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
		FROM
		[guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS CompanyAddress
		,@PAYMENTTERMS AS PaymentTerm
		,(select Note from [reservation].[Note] where ReservationID=RS.ReservationID and NoteTypeID=3) as GuestNotes
		,(select Note from [reservation].[Note] where ReservationID=RS.ReservationID and NoteTypeID=4) as Remarks
		,CASE When @TAXEXCEMPTION is not null then ISNULL(@VatAmount,0) ELSE 0 END as TaxExcemptionPercentage	
		,CASE When @TAXEXCEMPTION is not null then ISNULL(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
		,@DISCOUNTAMOUNT AS DiscountAmount
		,@DISCOUNTPERCENTAGE AS DiscountPercentage
		,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,@COMPLEMENTARYAMOUNT as Complementary,

		(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
		,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy


		FROM [reservation].[Reservation] RS
		inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId and  RP.Guest_CompanyId is null
		inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
		inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
		inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
		inner join [general].[Country] CN on AD.CountryID = CN.CountryID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		inner join [general].[Location] LC on RS.LocationID = LC.LocationID
		WHERE RS.ReservationID=@ReservationId and RP.DocumentTypeId=@DocTypeId
	  
		-- Advance Payment
		INSERT @TempTable
		SELECT 1,0,
		atr.TransactionDateTime AS TransactionDate, 
		--CASE WHEN (select CurrencyID from account.TransactionSummary where TransactionID=atr.TransactionID)=1 THEN atr.Remarks  ELSE  concat(atr.Remarks, '(Exchange Rate: ', atr.ExchangeRate, ')') END as ItemDescription,
		atr.Remarks,
		atr.Amount as AmountUSD,
		0 as BalanceUSD,
		atr.TransactionDateTime
		FROM [account].[Transaction] atr
		Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
		inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
		WHERE atr.ReservationID=@ReservationId

 
		--1. Room Charge
		INSERT @TempTable
		SELECT	2,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		- AmtBeforeTax as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		order by GL.TransDate;

	--2. Room Charge Discount
	IF @DISCOUNTPERCENTAGE>0
	BEGIN
		INSERT @TempTable
		SELECT	3,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', Discount','(', @DISCOUNTPERCENTAGE ,'%)' ) as ItemDescription,
		 ((@DISCOUNTPERCENTAGE / 100) * AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID  
		order by GL.TransDate;
	END

		--3. Room Charge COMPLEMENTARY
		INSERT @TempTable
		SELECT	4,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks +' Reversed Complimentary ('+convert(nvarchar(100), isnull(gl.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		order by GL.TransDate;
 
		--4. Room Charge VAT
		INSERT @TempTable
		SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ) as ItemDescription,
		CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(AmtBeforeTax - ((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE - AmtTax END as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		AND CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(AmtBeforeTax - ((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE -AmtTax END  < 0
		order by GL.TransDate;
	 
 
		--5. Room Charge VAT Complimentary
		--INSERT @TempTable
		--SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		--CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ,' Reversed (Complimentary)') as ItemDescription,
		----AmtTax as AmountUSD,
		----((gl.ComplimentaryPercentage/100) * (GL.TaxPer / 100)* (AmtBeforeTax - ((gl.ComplimentaryPercentage/100)*AmtBeforeTax)))   as AmountUSD,
		-- ((GL.TaxPer / 100)*(AmtBeforeTax - ((gl.ComplimentaryPercentage/100)* AmtBeforeTax))) as AmountUSD,
		----((40/100) *((109.09)-((40/100)*109.09)))
		--  -- *65.45
		--0 as BalanceUSD,
		--GL.TransDate
		--FROM [account].[GuestLedgerDetails] GL  
		--WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		--order by GL.TransDate;

 

		--6. Service Charge
		INSERT @TempTable
		SELECT 6,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		as ItemDescription,
		--CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) as ItemDescription,
		-gld.AmtBeforeTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 


		-- Service Charge Complimentary
		INSERT @TempTable
		SELECT 7,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		 +' Reversed Complimentary ('+CONVERT(nvarchar(50),isnull(gld.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		--CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) as ItemDescription,
		((isnull(gld.ComplimentaryPercentage,0) / 100)* gld.AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID  and IsComplimentary=1
		 
		-- Service Charge VAT
		INSERT @TempTable
		SELECT 8,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN GLD.Remarks IS NOT NULL THEN CONCAT(st.ServiceName ,' - ',gld.Remarks,' ',@RoomNo ,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)  ')
		ELSE CONCAT(st.ServiceName ,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)') END as ItemDescription,
		--gld.Remarks as ItemDescription,
		CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE - AmtTax END as AmountUSD,
		---gld.AmtTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 
		and  CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  -AmtTax END  < 0
		---- Service Charge VAT Complimentary
		--INSERT @TempTable
		--SELECT 9,
		--LedgerId,
		--FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		--CASE WHEN GLD.Remarks IS NOT NULL THEN CONCAT(st.ServiceName ,' - ',gld.Remarks,' ',@RoomNo ,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)  ')
		--ELSE CONCAT(st.ServiceName ,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)') END
		--+' Reversed (Complimentary)' as ItemDescription,
		----gld.Remarks as ItemDescription,
		----gld.AmtTax as AmountUSD,
		--((gld.TaxPer / 100) * ((gld.ComplimentaryPercentage / 100)* gld.AmtBeforeTax)) as AmountUSD,
		--0 as BalanceUSD,
		--gld.TransDate
		--FROM [account].[GuestLedgerDetails] gld
		--Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		--WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID and IsComplimentary=1


		-- Intrest  
		INSERT @TempTable
		SELECT 10,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		-gld.AmtBeforeTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		WHERE gld.FolioNo=@FolioNumber and gld.ServiceId=0 

		IF (@TAXEXCEMPTION is not null)
		begin
		insert into @TempTable	
		values
		(11,@ReservationId+991,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
		end		
	END
	ELSE
	BEGIN  ------ New Query Start ----------------------------------------------------------

	---- Amount Calculation

		 

		SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
		SELECT 
		@DISCOUNTPERCENTAGE=AdditionalDiscount,
		@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
		@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
		FROM reservation.Reservation WHERE ReservationID=@ReservationId



		SET @DISCOUNTAMOUNT=(SELECT (SUM(Discount)) FROM account.GuestLedgerDetails WHERE FolioNo=@FOLIONUMBER AND ServiceId=@SERVICETYPEID)
		 

		 
		SET @TotalAmountBeforeTax=(SELECT sum(case when ServiceId=18 then ISNULL(UnitPriceBeforeDiscount,AmtBeforeTax) else AmtBeforeTax end) from [account].[GuestLedgerDetails] where FolioNo=@FOLIONUMBER)
		SET @VatAmount =(SELECT sum(AmtTax- (AmtTax * (isnull(ComplimentaryPercentage,0)/100))) from [account].[GuestLedgerDetails] where FolioNo=@FOLIONUMBER)
		SET @TotalAmountAfterTax=(@TotalAmountBeforeTax - @DISCOUNTAMOUNT + @VatAmount)

		SET @COMPLEMENTARYAMOUNT = (select sum(AmtBeforeTax * (isnull(ComplimentaryPercentage,0) /100))
		FROM [account].[GuestLedgerDetails] 
		WHERE FolioNo=@FOLIONUMBER )
	SELECT DISTINCT
		CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
		,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
							+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
							+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
		,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
		,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
		,CASE WHEN RS.ActualCheckIn IS NULL THEN FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckIn,'dd-MMM-yyyy') END AS [ExpectedCheckIn]
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy') END AS [ExpectedCheckOut]
		,Nights as TotalDay
		,Rooms as RoomQty
		, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
		,RS.ReservationID as BookingNo
		,@PAIDTYPE as SalesType
		,RP.ProformaInvoiceNo
		,(select FORMAT(max(TransDate) ,'dd-MMM-yyyy') from account.GuestLedgerDetails where FolioNo=@FOLIONUMBER ) as InvoiceDate
		,'' as BankName
		,@RateEURO_USD as RateEURO_USD
		,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
		,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD
		,ISNULL(@TotalAmountBeforeTax,0) as TotalAmountBeforeTax
		,ISNULL(@VatAmount,0) as VatAmount
		,ISNULL(@TotalAmountAfterTax,0) as TotalAmountAfterTax
		,@TAXPERCENTAGE as TaxPercentage
		--,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) as ReceivedAmount
		,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0) +((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=1),0))) as ReceivedAmount
		,ISNULL(@CREATEDBY,'N/A') as CreatedByName
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
		
		,case when @TAXEXCEMPTION is not null then 
		((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0))-((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=1),0))) - @VatAmount) - @COMPLEMENTARYAMOUNT)
		else ((@TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=2),0) ))-((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and TransactionTypeID=1),0))) - @COMPLEMENTARYAMOUNT) end 
		as  TotalAmountDue

		,'8120.3.7087 (USD)' as USD
		,'8114.0.0343 (SRD)' as SRD
		,'8130.3.3111 (EURO)' as EURO
		,@RoomNo AS RoomNo
		,CASE WHEN RS.CompanyID =1 THEN '' ELSE (
		Select
		(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
		FROM
		[guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS CompanyAddress
		,@PAYMENTTERMS AS PaymentTerm
		,(select Note from [reservation].[Note] where ReservationID=RS.ReservationID and NoteTypeID=3) as GuestNotes
		,(select Note from [reservation].[Note] where ReservationID=RS.ReservationID and NoteTypeID=4) as Remarks
		,CASE When @TAXEXCEMPTION is not null then ISNULL(@VatAmount,0) ELSE 0 END as TaxExcemptionPercentage	
		,CASE When @TAXEXCEMPTION is not null then ISNULL(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
		,@DISCOUNTAMOUNT AS DiscountAmount
		,@DISCOUNTPERCENTAGE AS DiscountPercentage
		,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,@COMPLEMENTARYAMOUNT as Complementary,
		(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
		,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy
		FROM [reservation].[Reservation] RS
		inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId and  RP.Guest_CompanyId is null
		inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
		inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
		inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
		inner join [general].[Country] CN on AD.CountryID = CN.CountryID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		inner join [general].[Location] LC on RS.LocationID = LC.LocationID
		WHERE RS.ReservationID=@ReservationId and RP.DocumentTypeId=@DocTypeId
	 
		-- Advance Payment
		INSERT @TempTable
		SELECT 1,0,
		atr.TransactionDateTime AS TransactionDate, 
		--CASE WHEN (select CurrencyID from account.TransactionSummary where TransactionID=atr.TransactionID)=1 THEN atr.Remarks  ELSE  concat(atr.Remarks, '(Exchange Rate: ', atr.ExchangeRate, ')') END as ItemDescription,
		atr.Remarks,
		atr.Amount as AmountUSD,
		0 as BalanceUSD,
		atr.TransactionDateTime
		FROM [account].[Transaction] atr
		Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
		inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
		WHERE atr.ReservationID=@ReservationId

		--1. Room Charge
		INSERT @TempTable
		SELECT	2,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		- ISNULL(UnitPriceBeforeDiscount,AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		order by GL.TransDate;

	--2. Room Charge Discount
 
		INSERT @TempTable
		SELECT	3,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		--CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', Discount') as ItemDescription,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', Discount','(', GL.DiscountPercentage ,'%)' ) as ItemDescription,
		GL.Discount as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID  and GL.Discount>0
		order by GL.TransDate;
 

		--3. Room Charge COMPLEMENTARY
		INSERT @TempTable
		SELECT	4,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks +' Reversed Complimentary ('+convert(nvarchar(100), isnull(gl.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		order by GL.TransDate;
 
		--4. Room Charge VAT
		INSERT @TempTable
		SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ) as ItemDescription,
		CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(AmtBeforeTax - ((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE - AmtTax END as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		AND CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(AmtBeforeTax - ((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE -AmtTax END  < 0
		order by GL.TransDate;
	 
 
		--5. Room Charge VAT Complimentary
		--INSERT @TempTable
		--SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		--CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ,' Reversed (Complimentary)') as ItemDescription,
		----AmtTax as AmountUSD,
		----((gl.ComplimentaryPercentage/100) * (GL.TaxPer / 100)* (AmtBeforeTax - ((gl.ComplimentaryPercentage/100)*AmtBeforeTax)))   as AmountUSD,
		-- ((GL.TaxPer / 100)*(AmtBeforeTax - ((gl.ComplimentaryPercentage/100)* AmtBeforeTax))) as AmountUSD,
		----((40/100) *((109.09)-((40/100)*109.09)))
		--  -- *65.45
		--0 as BalanceUSD,
		--GL.TransDate
		--FROM [account].[GuestLedgerDetails] GL  
		--WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		--order by GL.TransDate;

 

		--6. Service Charge
		INSERT @TempTable
		SELECT 6,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		as ItemDescription,
		--CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) as ItemDescription,
		-gld.AmtBeforeTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 


		-- Service Charge Complimentary
		INSERT @TempTable
		SELECT 7,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		 +' Reversed Complimentary ('+CONVERT(nvarchar(50),isnull(gld.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		--CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) as ItemDescription,
		((isnull(gld.ComplimentaryPercentage,0) / 100)* gld.AmtBeforeTax) as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID  and IsComplimentary=1
		 
		-- Service Charge VAT
		INSERT @TempTable
		SELECT 8,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN GLD.Remarks IS NOT NULL THEN CONCAT(st.ServiceName ,' - ',gld.Remarks,' ',@RoomNo ,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)  ')
		ELSE CONCAT(st.ServiceName ,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)') END as ItemDescription,
		--gld.Remarks as ItemDescription,
		CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE - AmtTax END as AmountUSD,
		---gld.AmtTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 
		and  CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  -AmtTax END  < 0
		---- Service Charge VAT Complimentary
		--INSERT @TempTable
		--SELECT 9,
		--LedgerId,
		--FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		--CASE WHEN GLD.Remarks IS NOT NULL THEN CONCAT(st.ServiceName ,' - ',gld.Remarks,' ',@RoomNo ,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)  ')
		--ELSE CONCAT(st.ServiceName ,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd'),' VAT','(', gld.TaxPer,'%)') END
		--+' Reversed (Complimentary)' as ItemDescription,
		----gld.Remarks as ItemDescription,
		----gld.AmtTax as AmountUSD,
		--((gld.TaxPer / 100) * ((gld.ComplimentaryPercentage / 100)* gld.AmtBeforeTax)) as AmountUSD,
		--0 as BalanceUSD,
		--gld.TransDate
		--FROM [account].[GuestLedgerDetails] gld
		--Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		--WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID and IsComplimentary=1


		-- Intrest  
		INSERT @TempTable
		SELECT 10,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		-gld.AmtBeforeTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		WHERE gld.FolioNo=@FolioNumber and gld.ServiceId=0 

		IF (@TAXEXCEMPTION is not null)
		begin
		insert into @TempTable	
		values
		(11,@ReservationId+991,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
		end	
	END

		SELECT 
		FORMAT(TransactionDate,'dd MMM yyyy') as TransactionDate,
		ItemDescription,
		AmountUSD,
		sum(AmountUSD) over (order by TransactionDate2,DetailsNo,DSeq,ID) as BalanceUSD
		FROM @TempTable ORDER BY TransactionDate2,DetailsNo,DSeq,ID  ASC 

		
END
