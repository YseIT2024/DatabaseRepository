CREATE PROCEDURE [reservation].[spGetReservationInvoice_Report]  -- 11065,351,75,1,1
(		
	@FolioNumber int=null,
	@InvoiceNo int=null,
	@UserID int,	
	@LocationID int	,
	@FinalInvoice Bit
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @SERVICETYPEID INT =18

	DECLARE @ReservationID INT;
	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualCheckOut datetime;
	DECLARE @ActualStay int;
	DECLARE @RateCurrencyID INT;
	DECLARE @VatAmount DECIMAL (8,2);
	DECLARE @ServiceTaxAmount DECIMAL (8,2);
	DECLARE @CREATEDBY nvarchar(100);
	DECLARE @RATEEURO nvarchar(250);
	DECLARE @RATESRD nvarchar(250);

	DECLARE @BOOKEDBY nvarchar(100);
	DECLARE @CHECKEDINBY nvarchar(100);
	DECLARE @CHECKEDOUTBY nvarchar(100);
	
	DECLARE @RateEURO_USD nvarchar(250)=1;
	DECLARE @ExchangeRateUSD_SRD nvarchar(250);
	DECLARE @ExchangeRateEURO_SRD nvarchar(250);
	DECLARE @TAXPERCENTAGE nvarchar(250);
	DECLARE @PAIDCURRENCY nvarchar(250);
	DECLARE @PAIDTYPE nvarchar(250);
	DECLARE @TOTALNIGHTS nvarchar(250);
	DECLARE @PAYMENTTERMS nvarchar(250);
	DECLARE @DocTypeId int=2;

	DECLARE @TAXEXCEMPTION nvarchar(250);
	DECLARE @DISCOUNTPERCENTAGE decimal(18,2);
	DECLARE @DISCOUNTAMOUNT decimal(18,2);
 
	DECLARE @RoomNo varchar(250);
	DECLARE @ENDDATE DATE;

	DECLARE @CONFIRMEDDATE DATETIME;
	DECLARE @ROOMTYPEPE nvarchar(250);
	DECLARE @ReservationTypeId int=11; -- OTA Reservation
	DECLARE @IsOTABooking int=0;

	DECLARE @ISCOMPLEMENTARY INT;
	DECLARE @COMPLEMENTARYAMOUNT decimal(18,2)=0;
	DECLARE @COMPLEMENTARYTAX decimal(18,2)=0;
	DECLARE @InvoiceGuestId int;


	IF(EXISTS(SELECT R.ReservationID FROM reservation.Invoice I INNER JOIN reservation.Reservation R ON I.FolioNumber=R.FolioNumber where InvoiceNo=@InvoiceNo AND R.ReservationTypeID=@ReservationTypeId AND BillToType='Company'))
	BEGIN
		SET @IsOTABooking=0
	END

	SELECT @RATEEURO=CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate]))  FROM [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT(AccountingDate,'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=2
	SELECT @RATESRD=CONVERT(nvarchar(250),CONVERT(decimal(18,4), [Rate]))  FROM [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT([AccountingDate],'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=3

	SELECT @ReservationID= ReservationID FROM [reservation].[Reservation] WHERE FolioNumber=@FolioNumber

	SET @ROOMTYPEPE = (select [reservation].[fnGetRoomCategory](@ReservationID))
	SET @CONFIRMEDDATE = (select top(1) [DateTime] from reservation.ReservationStatusLog where ReservationStatusID=1 and ReservationID=@ReservationID)

	SELECT @ISCOMPLEMENTARY=CASE WHEN ReservationTypeID=10 then 1 else 0 end FROM reservation.Reservation WHERE ReservationID=@ReservationID

	--IF @ISCOMPLEMENTARY=1
	--	BEGIN
	--		SET @COMPLEMENTARYAMOUNT =(select SUM(AmtAfterTax) from account.GuestLedgerDetails where FolioNo=@FOLIONUMBER)
	--	END
			 
			set  @InvoiceGuestId=(select GuestID from reservation.Invoice where InvoiceNo=@InvoiceNo);

				SET @COMPLEMENTARYAMOUNT = (select sum(AmountBeforeTax * (isnull(ComplimentaryPercentage,0) /100))
										FROM reservation.InvoiceDetails
										WHERE  InvoiceNo=@InvoiceNo )


			SET @COMPLEMENTARYTAX =(
							SELECT Sum(A.Tax) From (
								SELECT  CASE WHEN IsComplimentary = 1 then SUM((isnull(ComplimentaryPercentage,0) / 100)*TaxAmount) 
								ELSE 0 END AS Tax
								FROM reservation.InvoiceDetails
								WHERE InvoiceNo=@InvoiceNo GROUP BY IsComplimentary) As A )

	SET @RoomNo=(select [reservation].[fnGetReserveredRoom] (@ReservationID))
	 
	-- DECLARE @TAXPERCENTAGE = (SELECT TaxRate FROM general.Tax WHERE IsActive=1)

    set @BOOKEDBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.ReservationID=@reservationId And RI.ReservationStatusID=1)
   
   set @CHECKEDINBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=3)
   set @CHECKEDOUTBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=4)

set @CREATEDBY=(Select  CONCAT(CD.FirstName ,' ',CD.LastName ,' (', r.[Role],')')  from [reservation].[Invoice]  RI
INNER JOIN [reservation].[Reservation] RS ON RI.FolioNumber=RS.FolioNumber
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			inner join [guest].[Guest] GT on RS.GuestID = GT.GuestID
			inner join app.[User] au on RI.CreatedBy=au.UserID
			inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			inner join app.UsersAndRoles ur on ur.UserID = au.UserID
			inner join app.Roles r on ur.RoleID=r.RoleId
			where RI.InvoiceNo=@InvoiceNo)
			 
SELECT @PAIDCURRENCY= [reservation].[fnGetPaidCurrency] (@reservationId)
SELECT @ExchangeRateUSD_SRD= [Rate] FROM  [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT(AccountingDate,'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=2
SELECT @ExchangeRateEURO_SRD=  [Rate] FROM [currency].[ExchangeRate]  WHERE AuthorizedFlag=0 AND FORMAT([AccountingDate],'yyyy-MM-dd')=FORMAT(getdate(), 'yyyy-MM-dd') and currencyid=3
SELECT @TOTALNIGHTS= NIGHTS FROM reservation.Reservation where RESERVATIONID=@reservationId
SELECT @PAIDTYPE=[reservation].[fnGetPaidType] (@reservationId)
SET @PAIDTYPE=ISNULL(@PAIDTYPE,'USD')

 
			SET @TAXPERCENTAGE = (SELECT  top(1)TaxPercent FROM reservation.InvoiceDetails where InvoiceNo=@InvoiceNo)


			SET @PAYMENTTERMS = (SELECT CONCAT(CAST(GC.CreditPeriod AS NVARCHAR(100)), ' Days Credit, @', CAST(GC.IntrestPercentageAfterCreditPeriod AS NVARCHAR(100)) , '% After Credit') FROM [guest].[GuestCompany] GC
						INNER JOIN [reservation].[Reservation] RR ON GC.CompanyID = RR.CompanyTypeID WHERE RR.ReservationID = @reservationId)
 
			SET @FOLIONUMBER= (SELECT FolioNumber FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo);
		

			SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationID)
			
			

		DECLARE @TempTable Table(DSeq INT,ID INT IDENTITY(1, 1),DetailsNo Int,
								TransactionDate DATE,
								ItemDescription nvarchar(150),
								AmountUSD decimal(18,2),
								BalanceUSD decimal(18,2),
								TransactionDate2 DATE)

 	DECLARE @NewQueryReservationId int =6580
	DECLARE @IsNewQuery int=0;
		
	IF((select ReservationID from reservation.Reservation where FolioNumber=@FolioNumber) > @NewQueryReservationId)
	BEGIN
		SET @IsNewQuery=1;
	END



	IF(@IsNewQuery=0)
		BEGIN    --- Old Query

SELECT @DISCOUNTPERCENTAGE=AdditionalDiscount,@ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationID
set @DISCOUNTAMOUNT =(SELECT ((@DISCOUNTPERCENTAGE/100)*sum(AmountBeforeTax)) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo and BillingCode=@SERVICETYPEID)
SET @VatAmount =(SELECT sum(TaxAmount- (TaxAmount* (isnull(ComplimentaryPercentage,0)/100))) from reservation.InvoiceDetails where InvoiceNo=@InvoiceNo) 
 


			SELECT 
			CASE WHEN INV.BillToType='Guest' THEN 'Guest ' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
			,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
								+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
								+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
			,TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS [GuestName]
			,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
			--,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]
			--,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]
			--,FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') AS [ExpectedCheckIn]
			--,FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') AS [ExpectedCheckOut]
			,CASE WHEN RS.ActualCheckIn IS NULL THEN FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckIn,'dd-MMM-yyyy') END AS [ExpectedCheckIn]
			,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy') END AS [ExpectedCheckOut]
			,Nights as TotalDay
			,Rooms as RoomQty
			, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
			,RS.ReservationID as BookingNo
			--,(select STRING_AGG(TransactionMode, ',')  from account.TransactionMode where TransactionModeID in ( select  distinct TransactionModeID from account.[Transaction] where ReservationID=@@ReservationID)) as SalesType
			,@PAIDTYPE as SalesType
			, 
			case when INV.InvoiceNumber is null then  CONVERT(nvarchar(50), INV.InvoiceNo)
			else  INV.InvoiceNumber  end 
			as ProformaInvoiceNo
			--,FORMAT(RP.CreatedDate,'dd-MMM-yyyy') as InvoiceDate
			--FORMAT(GETDATE(),'dd-MMM-yyyy') as InvoiceDate
			,(select FORMAT(MAX(InvoiceDate),'dd-MMM-yyyy') from reservation.Invoice where InvoiceNo=@InvoiceNo ) as InvoiceDate
			,'' as BankName

			,@RateEURO_USD as RateEURO_USD
			,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
			,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD

			--,RS.[TotalAmountBeforeTax] + ISNULL(@TotalAmountBeforeTax,0)  as TotalAmountBeforeTax
			--,RS.TotalTaxAmount + ISNULL(@VatAmount,0) as VatAmount 
			--,RS.[TotalAmountAfterTax] + ISNULL(@TotalAmountAfterTax,0)  as TotalAmountAfterTax

			, ISNULL(INV.TotalAmountBeforeTax,0) as TotalAmountBeforeTax
			--,ISNULL(INV.ServiceTaxAmount,0)
			,@VatAmount as VatAmount
			--,ISNULL(INV.TotalAmountAfterTax,0) 
			,ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount as TotalAmountAfterTax
			 


			,@TAXPERCENTAGE as TaxPercentage
			 

			,CASE WHEN @IsOTABooking=1 THEN 0.00 ELSE
   				CASE WHEN INV.ParentInvoiceNo IS NULL THEN ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId),0) ELSE '0.00' END
			 END
			as ReceivedAmount

			,@CREATEDBY as CreatedByName
			---,RP.CreatedDate as CreatedDate
			,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
			,CASE WHEN @IsOTABooking=0 THEN 
						CASE WHEN INV.ParentInvoiceNo IS NULL THEN
							case when @TAXEXCEMPTION is not null then 
							((ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount)  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId),0)) -@DISCOUNTAMOUNT - @VatAmount -@COMPLEMENTARYAMOUNT )
							ELSE
							((ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount)- (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId),0)) -@DISCOUNTAMOUNT - @COMPLEMENTARYAMOUNT )  
						END
			ELSE 
				case when @TAXEXCEMPTION is not null then 
				(ISNULL(INV.TotalAmountBeforeTax,0))
				ELSE
				(ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount - @COMPLEMENTARYAMOUNT)  
				END
			END
			ELSE
				CASE WHEN INV.ParentInvoiceNo IS NULL THEN
					case when @TAXEXCEMPTION is not null then 
					(INV.TotalAmountAfterTax - @DISCOUNTAMOUNT - @VatAmount  -@COMPLEMENTARYAMOUNT )
					ELSE
					(INV.TotalAmountAfterTax - @DISCOUNTAMOUNT -@COMPLEMENTARYAMOUNT)  
					END
				ELSE 
					case when @TAXEXCEMPTION is not null then 
					(INV.TotalAmountAfterTax - @VatAmount  )
					ELSE
					(INV.TotalAmountAfterTax)  
					END
			END
			END
			as  TotalAmountDue


			,'8120.3.7087 (USD)' as USD
			,'8114.0.0343 (SRD)' as SRD
			,'8130.3.3111 (EURO)' as EURO
			,@RoomNo AS RoomNo
			,CASE WHEN INV.BillToType='Guest' THEN '' ELSE CASE WHEN RS.CompanyID =1 THEN '' ELSE (
			Select
			(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
			FROM
			[guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END END AS CompanyAddress
			,@PAYMENTTERMS AS PaymentTerm
			,'' as GuestNotes
			,'' as Remarks
			,CASE When @TAXEXCEMPTION is not null then ISNULL(@VatAmount,0) ELSE 0 END as TaxExcemptionPercentage
			,CASE When @TAXEXCEMPTION is not null then ISNULL(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
			--,@DISCOUNTAMOUNT AS DiscountAmount
			,CASE WHEN INV.ParentInvoiceNo IS NULL THEN @DISCOUNTAMOUNT ELSE  0 END AS DiscountAmount

			,@DISCOUNTPERCENTAGE AS DiscountPercentage
			 ,@ROOMTYPEPE as RoomType
			,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate,
			(select GuestSignature  from [reservation].[GuestSignature] where InvoiceNo=@InvoiceNo and IsActive=1) as GuestSignature,
			(select ManagerSignature from [reservation].[GuestSignature] where InvoiceNo=@InvoiceNo and IsActive=1) as ManagerSignature
			,@COMPLEMENTARYAMOUNT as Complementary,

			(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
			,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy



			FROM [reservation].Invoice INV 
			inner join [reservation].Reservation RS on inv.FolioNumber=rs.FolioNumber
			--inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			inner join [guest].[Guest] GT on INV.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			WHERE RS.ReservationID=@ReservationID --and RP.DocumentTypeId=@DocTypeId 
			AND InvoiceNo=@InvoiceNo

			IF(EXISTS(SELECT InvoiceNo FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo AND ParentInvoiceNo IS NULL))
			BEGIN
				IF (@IsOTABooking=0)
					BEGIN
					-- Advance Payment
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
						WHERE atr.ReservationID=@ReservationID AND atr.GuestCompanyId=@InvoiceGuestId
					 END
			END
-- ROOM CHARGE
			INSERT @TempTable
			SELECT	 2,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,',',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription as ItemDescription,
			-RD.AmountBeforeTax as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID
			order by TransactionDate

-- ROOM CHARGE DISCOUNT
		IF (@DISCOUNTPERCENTAGE>0)
		BEGIN
			IF(EXISTS(SELECT InvoiceNo FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo AND ParentInvoiceNo IS NULL))
				BEGIN
					INSERT @TempTable
					SELECT	 2,RD.InvoiceDetailsId,
					FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
					CONCAT(RD.ServiceDescription,  ', Discount','(', @DISCOUNTPERCENTAGE ,'%)')  as ItemDescription,
					---RD.AmountBeforeTax as AmountUSD,
					((@DISCOUNTPERCENTAGE/100)*RD.AmountBeforeTax) as AmountUSD,
					0 as BalanceUSD,
					RD.TransactionDate
					FROM [reservation].Invoice RS
					inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
					WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID
					order by TransactionDate
				END
		END

		-- ROOM CHARGE Complimentary
			INSERT @TempTable
			SELECT	 3,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,',',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription + ' Reversed Complimentary ('+convert(nvarchar(50),isnull(RD.ComplimentaryPercentage,0))+'%)' as ItemDescription,
			--RD.AmountBeforeTax as AmountUSD,
			((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax) as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID and IsComplimentary=1
			order by TransactionDate

-- ROOM CHARGE VAT
			INSERT @TempTable
			SELECT	 4,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,' ', FORMAT(RD.TransactionDate,'MMM-dd') ,', VAT','(', RD.TaxPercent ,'%)') as ItemDescription,
			--RD.ServiceDescription AS ItemDescription, 
			CONCAT(RD.ServiceDescription,', VAT','(', RD.TaxPercent ,'%)') as ItemDescription,
			CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* rd.AmountBeforeTax)))
			ELSE - RD.TaxAmount END as AmountUSD,
			---RD.TaxAmount as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode=@SERVICETYPEID
			AND CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* rd.AmountBeforeTax)))
			ELSE - RD.TaxAmount END < 0
			order by TransactionDate
  
  ---- ROOM CHARGE VAT Complimentary
			--INSERT @TempTable
			--SELECT	 5,RD.InvoiceDetailsId,
			--FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			----CONCAT('Room Charge ', @RoomNo,' ', FORMAT(RD.TransactionDate,'MMM-dd') ,', VAT','(', RD.TaxPercent ,'%)') as ItemDescription,
			----RD.ServiceDescription AS ItemDescription, 
			--CONCAT(RD.ServiceDescription,', VAT','(', RD.TaxPercent ,'%)',' Reversed (Complimentary)') as ItemDescription,
			----RD.TaxAmount as AmountUSD,
			--((RD.TaxPercent / 100)*((RD.ComplimentaryPercentage/100)* RD.AmountBeforeTax))  as AmountUSD,
			--0 as BalanceUSD,
			--RD.TransactionDate
			--FROM [reservation].Invoice RS
			--inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			--WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode=@SERVICETYPEID and IsComplimentary=1
			--order by TransactionDate
 
 -- Service Charges
			INSERT @TempTable
			SELECT	 6,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT(st.ServiceName,' ',@RoomNo,' ',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription AS ItemDescription, 
			-RD.AmountBeforeTax as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode<>@SERVICETYPEID
			order by TransactionDate

			 -- Service Charges Complimentary
			INSERT @TempTable
			SELECT	 7,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT(st.ServiceName,' ',@RoomNo,' ',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription +' Reversed Complimentary ('+ convert(nvarchar(50),isnull(RD.ComplimentaryPercentage,0))+'%)' AS ItemDescription, 
			-- RD.AmountBeforeTax as AmountUSD,
			((isnull(RD.ComplimentaryPercentage,0) / 100)* RD.AmountBeforeTax) as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode<>@SERVICETYPEID  and IsComplimentary=1
			order by TransactionDate

			 -- Service Charges VAT
			INSERT @TempTable
			SELECT	 8,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--RD.ServiceDescription AS ItemDescription, 
			CONCAT(RD.ServiceDescription,' VAT','(', RD.TaxPercent,'%)') as ItemDescription,
			--CONCAT( st.ServiceName ,' ',@RoomNo,' ',FORMAT(RD.TransactionDate,'MMM-dd'),' VAT','(', RD.TaxPercent,'%)') as ItemDescription,
			---RD.TaxAmount as AmountUSD,
			CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax)))
			ELSE - RD.TaxAmount END as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode<>@SERVICETYPEID
			AND CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax)))
			ELSE - RD.TaxAmount END < 0
			order by TransactionDate

  -- Service Charges VAT Complimentary
			--INSERT @TempTable
			--SELECT	 9,RD.InvoiceDetailsId,
			--FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			----RD.ServiceDescription AS ItemDescription, 
			--CONCAT(RD.ServiceDescription,' VAT','(', RD.TaxPercent,'%)',' Reversed (Complimentary)') as ItemDescription,
			----CONCAT( st.ServiceName ,' ',@RoomNo,' ',FORMAT(RD.TransactionDate,'MMM-dd'),' VAT','(', RD.TaxPercent,'%)') as ItemDescription,
			----RD.TaxAmount as AmountUSD,
			----RD.TaxAmount as AmountUSD,
			--((RD.TaxPercent / 100) * ((RD.ComplimentaryPercentage / 100)* RD.AmountBeforeTax)) as AmountUSD,
			--0 as BalanceUSD,
			--RD.TransactionDate
			--FROM [reservation].Invoice RS
			--inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			--Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			--WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode<>@SERVICETYPEID  and IsComplimentary=1
			--order by TransactionDate
 

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
			(11,@ReservationID+998,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
			end		

			--IF(EXISTS(SELECT InvoiceNo FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo AND ParentInvoiceNo IS NULL))
			--BEGIN
			--	IF	@DISCOUNTAMOUNT>0
			--	begin
			--	insert into @TempTable	
			--	values
			--	(7,@ReservationID+999,@ENDDATE,'Additional Discount: '+ convert(varchar(100),@DISCOUNTPERCENTAGE)+'%',@DISCOUNTAMOUNT,0,@ENDDATE)
			--	end	
			--END
	END
	ELSE
	BEGIN    ---- New Query

	SELECT @DISCOUNTPERCENTAGE=AdditionalDiscount,@ENDDATE=ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID=@ReservationID
	set @DISCOUNTAMOUNT =isnull((SELECT SUM(Discount) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo and BillingCode=@SERVICETYPEID),0)
	SET @VatAmount =(SELECT sum(TaxAmount- (TaxAmount* (isnull(ComplimentaryPercentage,0)/100))) from reservation.InvoiceDetails where InvoiceNo=@InvoiceNo) 
 

		SELECT 
			CASE WHEN INV.BillToType='Guest' THEN 'Guest ' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END AS BillTo
			,(CASE When LEN(AD.[Street]) > 0 THEN Ad.[Street] +', ' ELSE '' END) + (CASE When LEN(AD.[City]) > 0 THEN AD.[City] +', ' ELSE '' END)
								+ (CASE When LEN(AD.[State]) > 0 THEN AD.[State] +', ' ELSE '' END) + CN.[CountryName] + (CASE When LEN(AD.[ZipCode]) > 0 THEN ', '+ AD.[ZipCode]  ELSE '' END)
								+ ', Mob : ' + AD.PhoneNumber + ' email : '+AD.Email as [Address]
			,CASE WHEN INV.BillToType='Guest' THEN TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) ELSE 
			(SELECT  TL.[Title] + ' ' + CD.[FirstName] + ' '+ CD.[LastName]  FROM [guest].[Guest] GT  
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID WHERE GT.GuestID=RS.GuestID) 
			END
			AS [GuestName]

			,RS.[ReservationStatusID],FORMAT(RS.[ActualCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckIn]	,FORMAT(RS.[ActualCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ActualCheckOut]	
			,CASE WHEN RS.ActualCheckIn IS NULL THEN FORMAT(RS.[ExpectedCheckIn],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckIn,'dd-MMM-yyyy') END AS [ExpectedCheckIn]
			,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(RS.[ExpectedCheckOut],'dd-MMM-yyyy') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy') END AS [ExpectedCheckOut]
			,Nights as TotalDay
			,Rooms as RoomQty
			, (Adults + Children  + ExtraAdults + ExtraChildJu + ExtraChildSe )as Occupancy
			,RS.ReservationID as BookingNo
			,@PAIDTYPE as SalesType
			,case when INV.InvoiceNumber is null then  CONVERT(nvarchar(50), INV.InvoiceNo)
			 else  INV.InvoiceNumber  end 
			 as ProformaInvoiceNo
			 
			,(select FORMAT(MAX(InvoiceDate),'dd-MMM-yyyy') from reservation.Invoice where InvoiceNo=@InvoiceNo ) as InvoiceDate
			,'' as BankName

			,@RateEURO_USD as RateEURO_USD
			,ISNULL(@ExchangeRateUSD_SRD,0) as ExchangeRateUSD_SRD
			,ISNULL(@ExchangeRateEURO_SRD,0) as ExchangeRateEURO_SRD
 

			, --ISNULL(INV.TotalAmountBeforeTax,0) as TotalAmountBeforeTax
			 ISNULL(INV.TotalAmountBeforeTax,0)+ISNULL(@DISCOUNTAMOUNT,0) as TotalAmountBeforeTax
			,@VatAmount as VatAmount
			 
			--,ISNULL(INV.TotalAmountAfterTax,0) as TotalAmountAfterTax
			 ,ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount as TotalAmountAfterTax
			,@TAXPERCENTAGE as TaxPercentage
			  
			,CASE WHEN @IsOTABooking=1 THEN 0.00 ELSE
   				CASE WHEN INV.ParentInvoiceNo IS NULL THEN 
				ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId AND TransactionTypeID=2),0)
				+
				ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId AND TransactionTypeID=1),0)
				ELSE '0.00' END
			 END
			as ReceivedAmount

			,@CREATEDBY as CreatedByName
			---,RP.CreatedDate as CreatedDate
			,CASE WHEN RS.ActualCheckOut IS NULL THEN FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') ELSE FORMAT(RS.ActualCheckOut,'dd-MMM-yyyy hh:mm tt') END  AS CreatedDate
			
			
			,CASE WHEN @IsOTABooking=0 
			THEN 
			CASE WHEN INV.ParentInvoiceNo IS NULL 
					THEN CASE WHEN @TAXEXCEMPTION is NOT NULL
					THEN ((ISNULL(INV.TotalAmountBeforeTax,0)) - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=2),0))+((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=1),0))) -@COMPLEMENTARYAMOUNT )
					ELSE ((ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount)-  ((ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=2),0))+((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=1),0))))  - @COMPLEMENTARYAMOUNT )  
			END
			ELSE 
				case when @TAXEXCEMPTION is not null then 
				(ISNULL(INV.TotalAmountBeforeTax,0))
				ELSE
				(ISNULL(INV.TotalAmountBeforeTax,0)+@VatAmount - @COMPLEMENTARYAMOUNT)  
				END
			END
			ELSE
				CASE WHEN INV.ParentInvoiceNo IS NULL THEN
					case when @TAXEXCEMPTION is not null then 
					(INV.TotalAmountAfterTax - @DISCOUNTAMOUNT - @VatAmount  -@COMPLEMENTARYAMOUNT )
					ELSE
					(INV.TotalAmountAfterTax - @DISCOUNTAMOUNT -@COMPLEMENTARYAMOUNT)  
					END
				ELSE 
					case when @TAXEXCEMPTION is not null then 
					(INV.TotalAmountAfterTax - @VatAmount  )
					ELSE
					(INV.TotalAmountAfterTax)  
					END
			END
			END
			as  TotalAmountDue

			 
		 -- ,CASE WHEN @TAXEXCEMPTION is NOT NULL
			--	THEN ((ISNULL(INV.TotalAmountBeforeTax,0))  - (ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=2),0))+((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=1),0))) - @COMPLEMENTARYAMOUNT )
			--	ELSE 
			--	((ISNULL(INV.TotalAmountAfterTax,0)) - ((ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=2),0))+((ISNULL((select sum(Amount) from account.[Transaction] where ReservationID=@ReservationID and GuestCompanyId=@InvoiceGuestId and TransactionTypeID=1),0)))) - @COMPLEMENTARYAMOUNT )  
			--END
			--as TotalAmountDue

			,'8120.3.7087 (USD)' as USD
			,'8114.0.0343 (SRD)' as SRD
			,'8130.3.3111 (EURO)' as EURO
			,@RoomNo AS RoomNo
			,CASE WHEN INV.BillToType='Guest' THEN '' ELSE CASE WHEN RS.CompanyID =1 THEN '' ELSE (
			Select
			(CASE When LEN(LTRIM(RTRIM(CompanyAddress))) > 0 THEN LTRIM(RTRIM(CompanyAddress)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyStreet))) > 0 THEN LTRIM(RTRIM(CompanyStreet)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyCity))) > 0 THEN LTRIM(RTRIM(CompanyCity)) +', ' ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyState))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyState))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyZIP))) > 0 THEN ', '+ LTRIM(RTRIM(CompanyZIP))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyPhoneNumber))) > 0 THEN ', Mob : '+ LTRIM(RTRIM(CompanyPhoneNumber))  ELSE '' END)
			+ (CASE When LEN(LTRIM(RTRIM(CompanyEmail))) > 0 THEN ', email : '+ LTRIM(RTRIM(CompanyEmail))  ELSE '' END)
			FROM
			[guest].[GuestCompany] where CompanyID=RS.CompanyTypeID) END END AS CompanyAddress
			,@PAYMENTTERMS AS PaymentTerm
			,'' as GuestNotes
			,'' as Remarks
			,CASE When @TAXEXCEMPTION is not null then ISNULL(@VatAmount,0) ELSE 0 END as TaxExcemptionPercentage
			,CASE When @TAXEXCEMPTION is not null then ISNULL(@TAXEXCEMPTION,'') ELSE '' END as TaxExcemptionNumber
		 
			,CASE WHEN INV.ParentInvoiceNo IS NULL THEN @DISCOUNTAMOUNT ELSE  0 END AS DiscountAmount

			,@DISCOUNTPERCENTAGE AS DiscountPercentage
			 ,@ROOMTYPEPE as RoomType
			,FORMAT(@CONFIRMEDDATE,'dd-MMM-yyyy hh:mm tt') as  ConfirmedDate,
			(select GuestSignature  from [reservation].[GuestSignature] where InvoiceNo=@InvoiceNo and IsActive=1) as GuestSignature,
			(select ManagerSignature from [reservation].[GuestSignature] where InvoiceNo=@InvoiceNo and IsActive=1) as ManagerSignature
			,@COMPLEMENTARYAMOUNT as Complementary,

			(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=RS.UserID) as BookedBy
			,(select CONCAT(CD.FirstName ,' ',CD.LastName) from app.[User] au inner join [contact].[Details] CD on au.ContactID=CD.ContactID 
			where UserID=(select ModifiedBy from reservation.ApprovalLog where  ApprovalStatus=1 and ProcessTypeId in (1,2,5,6) 
			and RefrenceNo=RS.ReservationID)) as BookingAprovalBy



			FROM [reservation].Invoice INV 
			inner join [reservation].Reservation RS on inv.FolioNumber=rs.FolioNumber
			--inner join [reservation].[ProformaInvoice] RP on RS.ReservationID= RP.ReservationId
			inner join [reservation].[ReservationType] RT on RS.ReservationTypeID = RT.ReservationTypeID
			inner join [reservation].[ReservationMode] RM on RS.ReservationModeID = RM.ReservationModeID
			inner join [guest].[Guest] GT on INV.GuestID = GT.GuestID
			inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [contact].[Address] AD on  CD.ContactID = AD.ContactID
			inner join [general].[Country] CN on AD.CountryID = CN.CountryID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			inner join [general].[Location] LC on RS.LocationID = LC.LocationID
			WHERE RS.ReservationID=@ReservationID --and RP.DocumentTypeId=@DocTypeId 
			AND InvoiceNo=@InvoiceNo

			IF(EXISTS(SELECT InvoiceNo FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo AND ParentInvoiceNo IS NULL))
			BEGIN
				IF (@IsOTABooking=0)
					BEGIN
					-- Advance Payment
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
						WHERE atr.ReservationID=@ReservationID AND atr.GuestCompanyId=@InvoiceGuestId
					 END
			END
-- ROOM CHARGE
			INSERT @TempTable
			SELECT	 2,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,',',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription as ItemDescription,
			-ISNULL(RD.UnitPriceBeforeDiscount,0) as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID
			order by TransactionDate
			 

-- ROOM CHARGE DISCOUNT

			IF(EXISTS(SELECT InvoiceNo FROM reservation.Invoice WHERE InvoiceNo=@InvoiceNo AND ParentInvoiceNo IS NULL))
				BEGIN
					INSERT @TempTable
					SELECT	 2,RD.InvoiceDetailsId,
					FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
					CONCAT(RD.ServiceDescription,', Discount','(', RD.DiscountPercentage ,'%)') as ItemDescription,
					ISNULL(RD.Discount,0)  as AmountUSD,
					0 as BalanceUSD,
					RD.TransactionDate
					FROM [reservation].Invoice RS
					inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
					WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID AND ISNULL(Discount,0)>0
					order by TransactionDate
				END
	


		-- ROOM CHARGE Complimentary
			INSERT @TempTable
			SELECT	 3,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,',',FORMAT(RD.TransactionDate,'MMM-dd')) as ItemDescription, 
			RD.ServiceDescription + ' Reversed Complimentary ('+convert(nvarchar(50),isnull(RD.ComplimentaryPercentage,0))+'%)' as ItemDescription,
			--RD.AmountBeforeTax as AmountUSD,
			((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax) as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode=@SERVICETYPEID and IsComplimentary=1
			order by TransactionDate

-- ROOM CHARGE VAT

			INSERT @TempTable
			SELECT	 4,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			--CONCAT('Room Charge ', @RoomNo,' ', FORMAT(RD.TransactionDate,'MMM-dd') ,', VAT','(', RD.TaxPercent ,'%)') as ItemDescription,
			--RD.ServiceDescription AS ItemDescription, 
			CONCAT(RD.ServiceDescription,', VAT','(', RD.TaxPercent ,'%)') as ItemDescription,
			CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* rd.AmountBeforeTax)))
			ELSE - RD.TaxAmount END as AmountUSD,
			---RD.TaxAmount as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode=@SERVICETYPEID
			AND CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* rd.AmountBeforeTax)))
			ELSE - RD.TaxAmount END < 0
			order by TransactionDate
  
 -- Service Charges
			INSERT @TempTable
			SELECT	 6,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			RD.ServiceDescription AS ItemDescription, 
			-RD.AmountBeforeTax as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode<>@SERVICETYPEID
			order by TransactionDate

			 -- Service Charges Complimentary
			INSERT @TempTable
			SELECT	 7,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			RD.ServiceDescription +' Reversed Complimentary ('+ convert(nvarchar(50),isnull(RD.ComplimentaryPercentage,0))+'%)' AS ItemDescription, 
			((isnull(RD.ComplimentaryPercentage,0) / 100)* RD.AmountBeforeTax) as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo  AND BillingCode<>@SERVICETYPEID  and IsComplimentary=1
			order by TransactionDate


			 -- Service Charges VAT
			INSERT @TempTable
			SELECT	 8,RD.InvoiceDetailsId,
			FORMAT(RD.TransactionDate,'dd-MMM-yyyy')  as TransDate,
			CONCAT(RD.ServiceDescription,' VAT','(', RD.TaxPercent,'%)') as ItemDescription,
			CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax)))
			ELSE - RD.TaxAmount END as AmountUSD,
			0 as BalanceUSD,
			RD.TransactionDate
			FROM [reservation].Invoice RS
			inner join [reservation].InvoiceDetails RD on RS.InvoiceNo = RD.InvoiceNo
			Inner join service.Type st on RD.BillingCode=st.ServiceTypeID
			WHERE RS.InvoiceNo=@InvoiceNo AND BillingCode<>@SERVICETYPEID
			AND CASE WHEN RD.IsComplimentary = 1 THEN - ((RD.TaxPercent / 100)*(RD.AmountBeforeTax - ((isnull(RD.ComplimentaryPercentage,0)/100)* RD.AmountBeforeTax)))
			ELSE - RD.TaxAmount END < 0
			order by TransactionDate

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
			(11,@ReservationID+998,@ENDDATE,'Tax Exempted Ref:' + convert(varchar(100),@TAXEXCEMPTION),@VatAmount,0,@ENDDATE)
			end		

	END

			SELECT 
			FORMAT(TransactionDate,'dd MMM yyyy') as TransactionDate,
			ItemDescription,
			AmountUSD,
			sum(AmountUSD) over (order by TransactionDate2,DetailsNo,DSeq,ID) as BalanceUSD
			FROM @TempTable ORDER BY TransactionDate2,DetailsNo,DSeq,ID  ASC 
		END
		 