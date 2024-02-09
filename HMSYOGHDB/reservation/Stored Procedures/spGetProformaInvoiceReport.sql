
CREATE PROCEDURE [reservation].[spGetProformaInvoiceReport] --7972,75,1
(
	@ReservationId int,
	@UserId int,
	@DocTypeId int=1
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
	DECLARE @ISCOMPLEMENTARY INT;
	DECLARE @COMPLEMENTARYAMOUNT decimal(18,2)=0;
	
SET @ROOMTYPEPE = (select [reservation].[fnGetRoomCategory](@ReservationId))
set @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationId)

		--set @CREATEDBY=(Select top(1)CD.FirstName from  app.[User] au
		--			inner join [contact].[Details] CD on au.ContactID=CD.ContactID where au.UserID=@UserId)

		Select top(1) @CREATEDBY=CONCAT(CD.FirstName ,' ',CD.LastName ,' (', r.[Role],')') from  app.[User] au
		inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
		inner join app.UsersAndRoles ur on ur.UserID = au.UserID
		inner join app.Roles r on ur.RoleID=r.RoleId
		where au.UserID=@UserId


		SELECT @PAIDCURRENCY= [reservation].[fnGetPaidCurrency] (@reservationId)
		SELECT @ExchangeRateUSD_SRD= CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate])) FROM  [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT(AccountingDate,'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=2
		SELECT @ExchangeRateEURO_SRD= CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate]))  FROM [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT([AccountingDate],'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=3
		SELECT @TOTALNIGHTS= NIGHTS FROM reservation.Reservation where RESERVATIONID=@reservationId
		SELECT @PAIDTYPE=[reservation].[fnGetPaidType] (@reservationId)
		SET @PAIDTYPE=ISNULL(@PAIDTYPE,'USD')

		SET @RoomNo=(select [reservation].[fnGetReserveredRoom] (@ReservationId))
		SET @TAXPERCENTAGE = (SELECT  top(1)TotalTax FROM reservation.reservationdetails where ReservationID=@ReservationId)

		SET @FOLIONUMBER= (SELECT FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationId);
		SET @PAYMENTTERMS = (SELECT CONCAT(CAST(GC.CreditPeriod AS NVARCHAR(100)), ' Days Credit, @', CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) , '% After Credit') FROM [guest].[GuestCompany] GC
								INNER JOIN [reservation].[Reservation] RR ON GC.CompanyID = RR.CompanyTypeID WHERE RR.ReservationID = @reservationId)

		SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
		SET @VatAmount=(SELECT sum(TotalTaxAmount) from reservation.ReservationDetails where ReservationID=@ReservationId)
		

		

		IF(not exists (select * from [reservation].[ProformaInvoice] where ReservationId=@ReservationId and DocumentTypeId=@DocTypeId))
			BEGIN
				DECLARE @OutputSequenceNo VARCHAR(255);
				--SET @AUTOID=(SELECT ISNULL(MAX(ProformaInvoiceId),1) FROM  [reservation].[ProformaInvoice])
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

  	 declare @TempTable Table(DSeq INT,ID INT IDENTITY(1, 1),DetailsNo Int,
		TransactionDate DATE,
		ItemDescription nvarchar(max),
		AmountUSD decimal(18,2),
		BalanceUSD decimal(18,2),
		TransactionDate2 DATE
		)

		DECLARE @NewQueryReservationId int =6580
		DECLARE @IsNewQuery int=0;
		
		IF(@ReservationId > @NewQueryReservationId)
		BEGIN
			SET @IsNewQuery=1;
		END
		
		IF(@IsNewQuery=0)
			BEGIN


SELECT 
@DISCOUNTAMOUNT=AdditionalDiscountAmount,
@DISCOUNTPERCENTAGE=AdditionalDiscount,
@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
FROM reservation.Reservation WHERE ReservationID=@ReservationId

IF @ISCOMPLEMENTARY=1
	BEGIN
		SET @COMPLEMENTARYAMOUNT =(select SUM(TotalAmountBeforeTax) from reservation.Reservation where ReservationId=@ReservationId)
	END

		SELECT
		CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
		,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
						+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
						+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
		,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
		,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
		--,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]
		--,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]
		,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') AS [ExpectedCheckIn]
		,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') AS [ExpectedCheckOut]
		,Nights as TotalDay
		,Rooms as RoomQty
		, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
		,RS.ReservationID as BookingNo
		--,(select STRING_AGG(TransactionMode, ',')  from account.TransactionMode where TransactionModeID in ( select  distinct TransactionModeID from account.[Transaction] where ReservationID=@ReservationId)) as SalesType
		,@PAIDTYPE as SalesType
		,RP.ProformaInvoiceNo
		,FORMAT(RP.CreatedDate,'dd-MMM-yyyy') as InvoiceDate
		,'' as BankName

		,@RateEURO_USD as RateEURO_USD
		,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
		,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD

		,RS.[TotalAmountBeforeTax]
		,case when RS.ReservationTypeID=10 then 0 else RS.TotalTaxAmount end as VatAmount
		,@TAXPERCENTAGE as TaxPercentage
		,case when RS.ReservationTypeID=10 then rs.TotalAmountBeforeTax else RS.[TotalAmountAfterTax] end TotalAmountAfterTax
		,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) as ReceivedAmount
		 
		,@CREATEDBY as CreatedByName
		,RP.CreatedDate as CreatedDate

		,CASE WHEN @ISCOMPLEMENTARY=0 THEN 
		case when @TAXEXCEMPTION is not null then 
		 ((RS.TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) ) - RS.TotalTaxAmount) - @DISCOUNTAMOUNT)
		 else ((RS.TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) )) - @DISCOUNTAMOUNT) end 
		 ELSE 0 END
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
		,CASE When @TAXEXCEMPTION is not null then	RS.TotalTaxAmount ELSE 0 END as TaxExcemptionPercentage	
		,CASE When @TAXEXCEMPTION is not null then Isnull(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
		,@DISCOUNTAMOUNT AS DiscountAmount
		,@DISCOUNTPERCENTAGE AS DiscountPercentage
		,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,@COMPLEMENTARYAMOUNT as Complementary
		, (select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
		,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy
		FROM [reservation].[Reservation] RS
		inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId
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
			atr.Remarks,
			--CASE WHEN (select CurrencyID from account.TransactionSummary where TransactionID=atr.TransactionID)=1 THEN atr.Remarks  ELSE  concat(atr.Remarks, '(Exchange Rate: ', atr.ExchangeRate, ')') END as ItemDescription,
			atr.Amount as AmountUSD,
			0 as BalanceUSD,
			atr.TransactionDateTime
			FROM [account].[Transaction] atr
			Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
			inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
			WHERE atr.ReservationID=@ReservationId

			-- Room Charge
			INSERT @TempTable
			SELECT	2,RD.ReservationDetailID,FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,

			CONCAT('Room Charge ', @RoomNo,', ', (SELECT TOP(1) S.Name FROM Products.Item I
			INNER JOIN Products.SubCategory S ON I.SubCategoryID=S.SubCategoryID WHERE I.ItemID=RD.ItemID),', ',FORMAT(RD.NightDate,'dd-MMM') ) as ItemDescription,

			-(RS.Rooms * RD.UnitPriceAfterTax-RD.TotalTaxAmount) as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId
			order by RD.NightDate;
	
			IF @ISCOMPLEMENTARY=1
			BEGIN
			INSERT @TempTable
			SELECT	4,RD.ReservationDetailID,FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
			CONCAT('Room Charge ', @RoomNo,', ', (SELECT TOP(1) S.Name FROM Products.Item I
			INNER JOIN Products.SubCategory S ON I.SubCategoryID=S.SubCategoryID WHERE I.ItemID=RD.ItemID),', ',FORMAT(RD.NightDate,'dd-MMM'),' Reversed Complimentary (100.00%)' ) as ItemDescription,
			(RD.UnitPriceAfterTax-RD.TotalTaxAmount) as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId
			order by RD.NightDate;

			--INSERT @TempTable
			--SELECT	5,RD.ReservationDetailID, FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,', VAT','(', RD.TotalTax,'%) , ',FORMAT(RD.NightDate,'dd-MMM'),' Reversed (Complimentary)') as ItemDescription,
			--RD.TotalTaxAmount as AmountUSD,
			--0 as BalanceUSD,
			--RD.NightDate
			--FROM [reservation].Reservation RS
			--inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			--WHERE RS.ReservationID=@ReservationId
			--order by RD.NightDate
			END


			--Room Charge VAT
			INSERT @TempTable
			SELECT	3,RD.ReservationDetailID, FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
			CONCAT('Room Charge ', @RoomNo,', VAT','(', RD.TotalTax,'%) , ',FORMAT(RD.NightDate,'dd-MMM')) as ItemDescription,
			-RD.TotalTaxAmount as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId and rs.ReservationTypeID!=10
			order by RD.NightDate
 

			IF (@TAXEXCEMPTION is not null)
			begin
			insert into @TempTable	
			values
			(4,@ReservationId+991,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
			end		

			IF	@DISCOUNTAMOUNT>0
			begin
			insert into @TempTable	
			values
			(5,@ReservationId+992,@ENDDATE,'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',@DISCOUNTAMOUNT,0,@ENDDATE)
			end	

		END
		ELSE  -- NEW QUERY START 
		BEGIN

		SELECT 
		@ENDDATE=CASE WHEN ActualCheckOut IS NOT NULL THEN ActualCheckOut ELSE  ExpectedCheckOut END,
		@ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end
		FROM reservation.Reservation WHERE ReservationID=@ReservationId

			SELECT 
		@DISCOUNTAMOUNT=sum(Discount * Rooms),
		@DISCOUNTPERCENTAGE=0
		FROM reservation.ReservationDetails WHERE ReservationID=@ReservationId

		IF @ISCOMPLEMENTARY=1
			BEGIN
				SET @COMPLEMENTARYAMOUNT =(select SUM(TotalAmountBeforeTax) from reservation.Reservation where ReservationId=@ReservationId)
			END

		 SELECT
		 CASE WHEN RS.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
		,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
						+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
						+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
		,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
		,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
		--,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]
		--,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]
		,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') AS [ExpectedCheckIn]
		,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') AS [ExpectedCheckOut]
		,Nights as TotalDay
		,Rooms as RoomQty
		, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
		,RS.ReservationID as BookingNo
		--,(select STRING_AGG(TransactionMode, ',')  from account.TransactionMode where TransactionModeID in ( select  distinct TransactionModeID from account.[Transaction] where ReservationID=@ReservationId)) as SalesType
		,@PAIDTYPE as SalesType
		,RP.ProformaInvoiceNo
		,FORMAT(RP.CreatedDate,'dd-MMM-yyyy') as InvoiceDate
		,'' as BankName

		,@RateEURO_USD as RateEURO_USD
		,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
		,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD

		,(RS.[TotalAmountBeforeTax]+@DISCOUNTAMOUNT) as TotalAmountBeforeTax
		,case when RS.ReservationTypeID=10 then 0 else RS.TotalTaxAmount end as VatAmount
		,@TAXPERCENTAGE as TaxPercentage
		,case when RS.ReservationTypeID=10 then rs.TotalAmountBeforeTax else RS.[TotalAmountAfterTax] end TotalAmountAfterTax
		,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) as ReceivedAmount


		,@CREATEDBY as CreatedByName
		,RP.CreatedDate as CreatedDate

		,CASE WHEN @ISCOMPLEMENTARY=0 THEN 
		case when @TAXEXCEMPTION is not null then 
		 ((RS.TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) ) - RS.TotalTaxAmount))
		 else ((RS.TotalAmountAfterTax  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationId),0) ))) end 
		 ELSE 0 END
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
		,CASE When @TAXEXCEMPTION is not null then	RS.TotalTaxAmount ELSE 0 END as TaxExcemptionPercentage	
		,CASE When @TAXEXCEMPTION is not null then Isnull(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
		,@DISCOUNTAMOUNT AS DiscountAmount
		,@DISCOUNTPERCENTAGE AS DiscountPercentage
		,@ROOMTYPEPE as RoomType
		,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate
		,@COMPLEMENTARYAMOUNT as Complementary
		, (select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
		,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy
		FROM [reservation].[Reservation] RS
		inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId
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
			atr.Remarks,
			--CASE WHEN (select CurrencyID from account.TransactionSummary where TransactionID=atr.TransactionID)=1 THEN atr.Remarks  ELSE  concat(atr.Remarks, '(Exchange Rate: ', atr.ExchangeRate, ')') END as ItemDescription,
			atr.Amount as AmountUSD,
			0 as BalanceUSD,
			atr.TransactionDateTime
			FROM [account].[Transaction] atr
			Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
			inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
			WHERE atr.ReservationID=@ReservationId

	-- Room Charge
			INSERT @TempTable
			SELECT	2,RD.ReservationDetailID,FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,

			CONCAT('Room Charge ', @RoomNo,', ', (SELECT TOP(1) S.Name FROM Products.Item I
			INNER JOIN Products.SubCategory S ON I.SubCategoryID=S.SubCategoryID WHERE I.ItemID=RD.ItemID),', ',FORMAT(RD.NightDate,'dd-MMM') ) as ItemDescription,

			-(RS.Rooms * RD.UnitPriceBeforeDiscount) as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId
			order by RD.NightDate;
	
	--Discount
		INSERT @TempTable
			SELECT	2,RD.ReservationDetailID,FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,

			CONCAT('Room Charge ', @RoomNo,', Discount ' ,'(', RD.DiscountPercentage,'%) , ',FORMAT(RD.NightDate,'dd-MMM')) as ItemDescription,

			(RD.Discount * RD.Rooms) as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId and RD.Discount>0
			order by RD.NightDate;


		IF @ISCOMPLEMENTARY=1
			BEGIN
				INSERT @TempTable
				SELECT	4,RD.ReservationDetailID,FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
				CONCAT('Room Charge ', @RoomNo,', ', (SELECT TOP(1) S.Name FROM Products.Item I
				INNER JOIN Products.SubCategory S ON I.SubCategoryID=S.SubCategoryID WHERE I.ItemID=RD.ItemID),', ',FORMAT(RD.NightDate,'dd-MMM'),' Reversed Complimentary (100.00%)' ) as ItemDescription,
				(RD.UnitPriceAfterTax-RD.TotalTaxAmount) as AmountUSD,
				0 as BalanceUSD,
				RD.NightDate
				FROM [reservation].Reservation RS
				inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
				WHERE RS.ReservationID=@ReservationId
				order by RD.NightDate;

				--INSERT @TempTable
				--SELECT	5,RD.ReservationDetailID, FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
				--CONCAT('Room Charge ', @RoomNo,', VAT','(', RD.TotalTax,'%) , ',FORMAT(RD.NightDate,'dd-MMM'),' Reversed (Complimentary)') as ItemDescription,
				--RD.TotalTaxAmount as AmountUSD,
				--0 as BalanceUSD,
				--RD.NightDate
				--FROM [reservation].Reservation RS
				--inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
				--WHERE RS.ReservationID=@ReservationId
				--order by RD.NightDate
			END


	--Room Charge VAT
			INSERT @TempTable
			SELECT	3,RD.ReservationDetailID, FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
			CONCAT('Room Charge ', @RoomNo,', VAT','(', RD.TotalTax,'%) , ',FORMAT(RD.NightDate,'dd-MMM')) as ItemDescription,
			-RD.TotalTaxAmount as AmountUSD,
			0 as BalanceUSD,
			RD.NightDate
			FROM [reservation].Reservation RS
			inner join [reservation].ReservationDetails RD on RS.ReservationID = RD.ReservationID
			WHERE RS.ReservationID=@ReservationId and rs.ReservationTypeID!=10
			order by RD.NightDate
 

			IF (@TAXEXCEMPTION is not null)
			begin
			insert into @TempTable	
			values
			(4,@ReservationId+991,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
			end		

			--IF	@DISCOUNTAMOUNT>0
			--begin
			--insert into @TempTable	
			--values
			--(5,@ReservationId+992,@ENDDATE,'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',@DISCOUNTAMOUNT,0,@ENDDATE)
			--end	

		END


		SELECT 
		FORMAT(TransactionDate,'dd MMM yyyy') as TransactionDate,
		ItemDescription,
		AmountUSD,
		sum(AmountUSD) over (order by TransactionDate2,DetailsNo,DSeq,ID) as BalanceUSD
		FROM @TempTable ORDER BY TransactionDate2,DetailsNo,DSeq,ID  ASC 

END
