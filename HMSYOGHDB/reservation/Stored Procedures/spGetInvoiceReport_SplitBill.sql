CREATE PROCEDURE [reservation].[spGetInvoiceReport_SplitBill]   --1127,75,2,3,'Company'
(
	@ReservationId int,
	@UserId int,
	@DocTypeId int=2,
	@GuestId int,
	@Type nvarchar(50) 
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
	DECLARE @ADVANCE_PAYMENT decimal(18,2)=0;
	DECLARE @RETURN_ADVANCE_PAYMENT decimal(18,2)=0;
	DECLARE @TotalAmountBeforeTax DECIMAL(18,2);
	DECLARE @TotalAmountAfterTax DECIMAL(18,2);

	IF(@Type='Guest')
	BEGIN
		SET @ADVANCE_PAYMENT=ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId and GuestCompanyTypeId=1 and GuestCompanyId=@GuestId AND TransactionTypeID=2),0)
		SET @RETURN_ADVANCE_PAYMENT=ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId and GuestCompanyTypeId=1 and GuestCompanyId=@GuestId AND TransactionTypeID=1),0)
	END
	IF(@Type='Company')
	BEGIN
		SET @ADVANCE_PAYMENT=ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId  and GuestCompanyTypeId>1 and GuestCompanyId=@GuestId AND TransactionTypeID=2),0)
		SET @RETURN_ADVANCE_PAYMENT=ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationId  and GuestCompanyTypeId>1 and GuestCompanyId=@GuestId AND TransactionTypeID=1),0)
	END

	SET @ROOMTYPEPE = (select [reservation].[fnGetRoomCategory](@ReservationId))
	SET @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationId)

		IF(not exists (select * from [reservation].[ProformaInvoice] where ReservationId=@ReservationId and DocumentTypeId=@DocTypeId and Guest_CompanyId=@GuestId and [Type]=@Type))
		BEGIN
			DECLARE @OutputSequenceNo VARCHAR(255);
			EXEC [report].spGetReportSequenceNo @DocTypeId = @DocTypeId, @SequenceNo = @OutputSequenceNo OUTPUT;

			INSERT INTO [reservation].[ProformaInvoice](
			[DocumentTypeId]
			,[ReservationId]
			,[ProformaInvoiceNo]
			,[CreatedDate]
			,[CreatedBy]
			,[Guest_CompanyId]
			,[Type]
			)
			VALUES
			(@DocTypeId,@ReservationId,@OutputSequenceNo,GETDATE(),@UserID,@GuestId,@Type)
		END



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
		BEGIN  -- Old Query----------------

		---- Amount Calculation-----------
		 
		SET @TotalAmountBeforeTax =(select sum(a) from(
		SELECT 
		(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax ) as a
		from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)

	 
		SET @VatAmount =(select sum(a) from(
		SELECT 
		((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax ) * g.TaxPer/100)
		-
		(((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax ) * g.TaxPer/100)* (isnull(ComplimentaryPercentage,0)/100))
		as a
		from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)

		--SET @VatAmount =(select sum(amttax)
		--from [account].[GuestLedgerDetails] ag
		--where ag.FolioNo=@FOLIONUMBER and 
		--ag.ServiceId in (select ServiceId from [guest].[OTAServices] ot where ot.GuestID_CompanyID=@GuestId and ot.[Type]=@Type and 
		--ot.ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=@FOLIONUMBER) and ot.ServicePercent>0))	

		SET @TotalAmountAfterTax =(@TotalAmountBeforeTax + @VatAmount)
		 

		SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
		SELECT 
		@DISCOUNTPERCENTAGE=AdditionalDiscount,
		@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
		@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
		FROM reservation.Reservation WHERE ReservationID=@ReservationId

		SET @DISCOUNTAMOUNT=(SELECT ((@DISCOUNTPERCENTAGE/100) * SUM(AmtBeforeTax)) FROM account.GuestLedgerDetails WHERE FolioNo=@FOLIONUMBER AND ServiceId=@SERVICETYPEID)
		 
	 


SET @COMPLEMENTARYAMOUNT =(select sum(a) from(
SELECT 
(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax )*(isnull(ComplimentaryPercentage,0) /100) as a
from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)

		SELECT
		CASE WHEN @Type='Guest' THEN (select FullName from [guest].[vwGuestDetails] where GuestID=@GuestId) ELSE 
		(Select CompanyName from [guest].[GuestCompany] where CompanyID=@GuestId) END AS BillTo

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
		,(select ProformaInvoiceNo from [reservation].[ProformaInvoice] RP where RP.ReservationId=RS.ReservationId and RP.DocumentTypeId=@DocTypeId 
			and  RP.Guest_CompanyId=@GuestId and RP.[Type]=@Type ) as  ProformaInvoiceNo
		 
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
		,@ADVANCE_PAYMENT + @RETURN_ADVANCE_PAYMENT AS ReceivedAmount
		,ISNULL(@CREATEDBY,'N/A') as CreatedByName
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
		,case when @TAXEXCEMPTION is not null then 
		((@TotalAmountAfterTax  - (@ADVANCE_PAYMENT)-@RETURN_ADVANCE_PAYMENT - @VatAmount) - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT)
		else ((@TotalAmountAfterTax  - (@ADVANCE_PAYMENT))-@RETURN_ADVANCE_PAYMENT - @DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT) end 
		as  TotalAmountDue
		,'8120.3.7087 (USD)' as USD
		,'8114.0.0343 (SRD)' as SRD
		,'8130.3.3111 (EURO)' as EURO
		,@RoomNo AS RoomNo
		,CASE WHEN @Type='Guest' then '' ELSE  (
		 Select
		(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
		FROM
		[guest].[GuestCompany] where CompanyID=@GuestId) END AS CompanyAddress
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
		--inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId 
		inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
		inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
		inner join [guest].[Guest] GT on RS.GuestID= GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
		inner join [general].[Country] CN on AD.CountryID = CN.CountryID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		inner join [general].[Location] LC on RS.LocationID = LC.LocationID
		WHERE RS.ReservationID=@ReservationId

		-- Advance Payment
		IF(@Type='Guest')
			BEGIN
				INSERT @TempTable
				SELECT 1,0,
				atr.TransactionDateTime AS TransactionDate, 
				atr.Remarks,
				atr.Amount as AmountUSD,
				0 as BalanceUSD,
				atr.TransactionDateTime
				FROM [account].[Transaction] atr
				Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
				inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
				WHERE atr.ReservationID=@ReservationId and atr.GuestCompanyTypeId=1 AND atr.GuestCompanyId=@GuestId
			END
		IF(@Type='Company')
			BEGIN
				INSERT @TempTable
				SELECT 1,0,
				atr.TransactionDateTime AS TransactionDate, 
				atr.Remarks,
				atr.Amount as AmountUSD,
				0 as BalanceUSD,
				atr.TransactionDateTime
				FROM [account].[Transaction] atr
				Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
				inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
				WHERE atr.ReservationID=@ReservationId and atr.GuestCompanyTypeId>1 AND atr.GuestCompanyId=@GuestId
			END

		--1. Room Charge
		INSERT @TempTable
		SELECT	2,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		--  - AmtBeforeTax as AmountUSD,
		-(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * AmtBeforeTax) as AmountUSD,

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
		((isnull(gl.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * GL.AmtBeforeTax )) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		order by GL.TransDate;
 
		--4. Room Charge VAT
		INSERT @TempTable
		SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ) as ItemDescription,
		CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * AmtBeforeTax) - ((isnull(gl.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * AmtBeforeTax))))
		ELSE - (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
					where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
					and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * AmtTax)  END as AmountUSD,
					0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		AND CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(AmtBeforeTax - ((isnull(gl.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE -AmtTax END  < 0
		order by GL.TransDate;

		--6. Service Charge
		INSERT @TempTable
		SELECT 6,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		as ItemDescription,
		--CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) as ItemDescription,
		---gld.AmtBeforeTax as AmountUSD,
		-(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax) as AmountUSD,

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
		((isnull(gld.ComplimentaryPercentage,0) / 100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax )) as AmountUSD,
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
		CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax) - ((isnull(gld.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax))))
		ELSE - (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
				where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
				and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtTax) END as AmountUSD,
		---gld.AmtTax as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 
		and  CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  -AmtTax END  < 0
		 
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
	BEGIN --- New Query Start

	---- Amount Calculation
		 
SET @TotalAmountBeforeTax=(select sum(a) from(
SELECT 
(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * CASE WHEN ServiceId=18 THEN G.UnitPriceBeforeDiscount ELSE G.AmtBeforeTax END) as a
from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)


--SET @DISCOUNTAMOUNT=(SELECT SUM(Discount) from [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)
SET @DISCOUNTAMOUNT=(select sum(a) from(
SELECT 
(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * Discount) as a
from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)
 
SET @VatAmount =(select sum(a) from(
		SELECT 
		((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax ) * g.TaxPer/100)
		-
		(((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * G.AmtBeforeTax ) * g.TaxPer/100)* (isnull(ComplimentaryPercentage,0)/100))
		as a
		from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)


SELECT 
@DISCOUNTPERCENTAGE=AdditionalDiscount,
@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
FROM reservation.Reservation WHERE ReservationID=@ReservationId

--SET @DISCOUNTAMOUNT=(SELECT ((@DISCOUNTPERCENTAGE/100) * SUM(AmtBeforeTax)) FROM account.GuestLedgerDetails WHERE FolioNo=@FOLIONUMBER AND ServiceId=@SERVICETYPEID)
		 


 SET @TotalAmountAfterTax=(@TotalAmountBeforeTax - @DISCOUNTAMOUNT + @VatAmount)
		 

 SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
  

SET @COMPLEMENTARYAMOUNT =(select sum(a) from(
SELECT 
(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
and o.GuestID_CompanyID=@GuestId and o.ServiceID=G.ServiceId and o.[Type]=@Type) / 100) * CASE WHEN ServiceId=18 THEN G.UnitPriceBeforeDiscount ELSE G.AmtBeforeTax END)*(isnull(ComplimentaryPercentage,0) /100) as a
from [account].[GuestLedgerDetails] G where FolioNo=@FOLIONUMBER) as aa)


		 SELECT
		CASE WHEN @Type='Guest' THEN  (select FullName from [guest].[vwGuestDetails] where GuestID=@GuestId )ELSE 
		(Select CompanyName from [guest].[GuestCompany] where CompanyID=@GuestId) END AS BillTo

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
		,(select ProformaInvoiceNo from [reservation].[ProformaInvoice] RP where RP.ReservationId=RS.ReservationId and RP.DocumentTypeId=@DocTypeId 
			and  RP.Guest_CompanyId=@GuestId and RP.[Type]=@Type ) as  ProformaInvoiceNo
		 
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
		,@ADVANCE_PAYMENT + @RETURN_ADVANCE_PAYMENT AS ReceivedAmount
		,ISNULL(@CREATEDBY,'N/A') as CreatedByName
		,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
		,case when @TAXEXCEMPTION is not null then 
		((@TotalAmountAfterTax  - @ADVANCE_PAYMENT- @RETURN_ADVANCE_PAYMENT - @VatAmount)  - @COMPLEMENTARYAMOUNT)
		else (@TotalAmountAfterTax  - @ADVANCE_PAYMENT -@RETURN_ADVANCE_PAYMENT - @COMPLEMENTARYAMOUNT) end 
		as  TotalAmountDue
		,'8120.3.7087 (USD)' as USD
		,'8114.0.0343 (SRD)' as SRD
		,'8130.3.3111 (EURO)' as EURO
		,@RoomNo AS RoomNo
		,CASE WHEN @Type='Guest' then '' ELSE (
		 Select
		(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
		+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
		FROM
		[guest].[GuestCompany] where CompanyID=@GuestId) END  AS CompanyAddress
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
		--inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId 
		inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
		inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
		inner join [guest].[Guest] GT on RS.GuestID= GT.GuestID
		inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
		inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
		inner join [general].[Country] CN on AD.CountryID = CN.CountryID
		inner join [person].[Title] TL on CD.TitleID = TL.TitleID
		inner join [general].[Location] LC on RS.LocationID = LC.LocationID
		WHERE RS.ReservationID=@ReservationId

		-- Advance Payment
		IF(@Type='Guest')
			BEGIN
				INSERT @TempTable
				SELECT 1,0,
				atr.TransactionDateTime AS TransactionDate, 
				atr.Remarks,
				atr.Amount as AmountUSD,
				0 as BalanceUSD,
				atr.TransactionDateTime
				FROM [account].[Transaction] atr
				Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
				inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
				WHERE atr.ReservationID=@ReservationId and atr.GuestCompanyTypeId=1 AND atr.GuestCompanyId=@GuestId
			END
		IF(@Type='Company')
			BEGIN
				INSERT @TempTable
				SELECT 1,0,
				atr.TransactionDateTime AS TransactionDate, 
				atr.Remarks,
				atr.Amount as AmountUSD,
				0 as BalanceUSD,
				atr.TransactionDateTime
				FROM [account].[Transaction] atr
				Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
				inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
				WHERE atr.ReservationID=@ReservationId and atr.GuestCompanyTypeId>1 AND atr.GuestCompanyId=@GuestId
			END

		--1. Room Charge
		INSERT @TempTable
		SELECT	2,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks as ItemDescription,
		--  - AmtBeforeTax as AmountUSD,
		-(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * GL.UnitPriceBeforeDiscount) as AmountUSD,

		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID
		order by GL.TransDate;

	--2. Room Charge Discount
 
		INSERT @TempTable
		SELECT	3,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', Discount','(', GL.DiscountPercentage ,'%)' ) as ItemDescription,
		(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * GL.Discount) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND GL.Discount>0
		order by GL.TransDate;
	 

		--3. Room Charge COMPLEMENTARY
		INSERT @TempTable
		SELECT	4,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		Remarks +' Reversed Complimentary ('+convert(nvarchar(100), isnull(gl.ComplimentaryPercentage,0))+'%)' as ItemDescription,
		((isnull(gl.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * GL.UnitPriceBeforeDiscount )) as AmountUSD,
		0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID AND IsComplimentary=1
		order by GL.TransDate;
 
		--4. Room Charge VAT
		INSERT @TempTable
		SELECT	5,GL.LedgerId,FORMAT(GL.TransDate,'dd-MMM-yyyy')  as TransDate,
		CONCAT('Room Charges ', @RoomNo,' ',FORMAT(GL.TransDate,'MMM-dd'),', VAT','(', GL.TaxPer ,'%)' ) as ItemDescription,
		CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * UnitPriceBeforeDiscount) - ((isnull(gl.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * UnitPriceBeforeDiscount))))
		ELSE - (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
					where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=GL.FolioNo)
					and o.GuestID_CompanyID=@GuestId and o.ServiceID=GL.ServiceId and o.[Type]=@Type) / 100) * AmtTax)  END as AmountUSD,
					0 as BalanceUSD,
		GL.TransDate
		FROM [account].[GuestLedgerDetails] GL  
		WHERE GL.FolioNo=@FOLIONUMBER AND  GL.ServiceId=@SERVICETYPEID 
		AND CASE WHEN GL.IsComplimentary = 1 THEN - ((GL.TaxPer / 100)*(UnitPriceBeforeDiscount - ((isnull(gl.ComplimentaryPercentage,0)/100)* UnitPriceBeforeDiscount)))
		ELSE -AmtTax END  < 0
		order by GL.TransDate;

		--6. Service Charge
		INSERT @TempTable
		SELECT 6,
		LedgerId,
		FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
		CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else 
		CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END
		as ItemDescription,
		-(((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax) as AmountUSD,
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
		((isnull(gld.ComplimentaryPercentage,0) / 100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
		where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=FolioNo)
		and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax )) as AmountUSD,
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
		CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*((((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax) - ((isnull(gld.ComplimentaryPercentage,0)/100)* (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
													where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
													and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtBeforeTax))))
		ELSE - (((select isnull(o.ServicePercent,0) from [guest].[OTAServices] o 
				where ReservationID=(select ReservationID from reservation.Reservation where FolioNumber=gld.FolioNo)
				and o.GuestID_CompanyID=@GuestId and o.ServiceID=gld.ServiceId and o.[Type]=@Type) / 100) * gld.AmtTax) END as AmountUSD,
		0 as BalanceUSD,
		gld.TransDate
		FROM [account].[GuestLedgerDetails] gld
		Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
		WHERE gld.FolioNo=@FolioNumber   and st.ServiceTypeID<>@SERVICETYPEID 
		and  CASE WHEN gld.IsComplimentary = 1 THEN - ((gld.TaxPer / 100)*(AmtBeforeTax - ((isnull(gld.ComplimentaryPercentage,0)/100)* AmtBeforeTax)))
		ELSE  -AmtTax END  < 0
		 
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