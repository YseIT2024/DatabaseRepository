

CREATE PROCEDURE [reservation].[spGetReservationView] --1622,1,1 
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int 
)
AS
BEGIN
	
	--Declare @ReservationID int=6037,@LocationID int,@DrawerID int 
	SET NOCOUNT ON;	

	DECLARE @LastReservationID int=6606;

	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualStay int;
	DECLARE @Nights int;	
	DECLARE @ReservationStatusID int;
	DECLARE @RateCurrencyID int;
	DECLARE @CurrencyID int;
	DECLARE @DateDifference int;
	DECLARE @ExpectedCheckInDate datetime;
	DECLARE @ExpectedCheckOutDate datetime;
	DECLARE @RequiredReservationDeposit decimal;
	DECLARE @CurrencyCode varchar(20) = (Select CurrencyCode from [currency].[Currency] where CurrencyID=1)
 
DECLARE @HotelTermsAndConditions varchar(MAX)='';

	 
	SELECT  @ActualCheckIn = r.ActualCheckIn
	,@ReservationStatusID = ReservationStatusID
	,@CurrencyID = r.CurrencyID
	FROM reservation.Reservation r
	 
	WHERE r.ReservationID = @ReservationID AND r.LocationID = @LocationID

    SELECT  RR.ReservationID [ReservationID]
	,CASE WHEN RR.FolioNumber > 0 THEN  LTRIM(STR(RR.FolioNumber)) ELSE 'N/A' END [FolioNumber]
	,[ReservationStatus]
	,ReservationMode
	,CASE WHEN ActualCheckIn IS NULL THEN '' ELSE FORMAT([ActualCheckIn],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckIn]
	,CASE WHEN ActualCheckOut IS NULL THEN '' ELSE FORMAT([ActualCheckOut],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckOut]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]	
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]	
	--,FORMAT(RR.[DateTime],'dd-MMM-yyyy hh:mm tt') AS [DateTime]
	--,[dbo].[GetDatetimeBasedonTimezone] (RR.[DateTime]), 'dd-MMM-yyyy hh:mm tt'  AS [DateTime]
       ,FORMAT(CONVERT(datetime, [dbo].[GetDatetimeBasedonTimezone](RR.[DateTime])), 'dd-MMM-yyyy hh:mm tt') AS [DateTime]
	---,FORMAT(CONVERT([dbo].[GetDatetimeBasedonTimezone](RR.[DateTime])), 'dd-MMM-yyyy hh:mm tt') AS [DateTime]
	
	,TL.[Title] + ' ' + CD.FirstName +' '+ CD.LastName as [Name]  
	,CA.[Email] Email
	,RR.[Adults] 
	,RR.[Children]
	,RR.[Rooms]
	,[Nights]   
	,CASE WHEN RR.ReservationStatusID = 3 THEN 
		(
			CASE WHEN (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ExpectedCheckOut])) END
		)
		WHEN RR.ReservationStatusID = 4 THEN 
		(
			CASE WHEN DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut]) <= 0 THEN 1 ELSE (DATEDIFF(DAY, [ActualCheckIn], [ActualCheckOut])) END
		)
	ELSE [Nights] END [ActualStay]
	,[ReservationType]		
     ,AT.TransactionMode as [Hold]
	,AdditionalDiscount Discount      
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address]	
	,0.00 [Exemption]
	--,COM.CompanyName [BillTo]
	--,GGC.CompanyName [BillTo]
	---,CASE WHEN RR.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RR.CompanyTypeID) END AS BillTo --Added by Arabinda on 21 Aug 23
	,CASE WHEN RR.CompanyID = 1 THEN 'Guest' ELSE 'Company' END AS BillTo
	,EC.EmrContactName
	,EC.EmrContactNumber
	,EC.EmrContactRelation
	,RN.Note as ReservationRemarks -- reservation Remarks
	,RR.OnlineReservationID
	,GC.CountryName
	,RR.ReservationTypeID
	,ISNULL(CA.PhoneNumber,'')As PhoneNumber
	,@HotelTermsAndConditions as HotelTermsAndConditions
	,@CurrencyCode as CurrencyCode
	FROM reservation.Reservation RR
	--inner join reservation.ReservationDetails RD on RD.ReservationID=RR.ReservationID
	inner join reservation.ReservationStatus RS on RS.ReservationStatusID=RR.ReservationStatusID
	inner join reservation.ReservationMode RM on RM.ReservationModeID=RR.ReservationModeID
	inner join guest.Guest GG on GG.GuestID=RR.GuestID
	inner join contact.Details CD on CD.ContactID=GG.ContactID
	inner join [person].[Title] TL on CD.TitleID = TL.TitleID
	inner join reservation.ReservationType RT on RT.ReservationTypeID=RR.ReservationTypeID
	inner join contact.Address CA on CA.ContactID=CD.ContactID
	inner join general.Country GC on GC.CountryID=CA.CountryID
	--inner join general.Company COM on COM.CompanyID=RR.CompanyID	--Commented by Arabinda on 18 Aug 23 as [guest].[GuestCompany] is in use 
	--INNER JOIN [guest].[GuestCompany] GGC ON GGC.CompanyID=RR.CompanyTypeID --Added by Arabinda on 18 Aug 23 
	inner join account.TransactionMode AT on AT.TransactionModeID=RR.Hold_TransactionModeID
	left  join [reservation].[Note] RN on RR.ReservationID = RN.ReservationID and NoteTypeID = 5
	left join [contact].[EmergencyContact] EC on RR.ReservationID = EC.ReservationID
	WHERE RR.ReservationID = @ReservationID 
	
	 

	--Get Night dates and rate
	select IT.ItemID,SC.Name, IT.ItemName, RD.NightDate,RD.Rooms, RD.LineTotal,RD.TotalTaxAmount,SC.SubCategoryID,RD.ReservationDetailID
	from [reservation].[ReservationDetails] RD
		INNER JOIN [Products].[Item] IT ON RD.ItemID = IT.ItemID
		INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID  ----LINE ADDED BY MURUGESH S
		where ReservationID = @ReservationID
		ORDER BY IT.ItemID

	--Get Geust mates info
	SELECT RG.ReservationID,RG.GuestMatesID, RG.Nationality as CountryID, CT.CountryName, RG.Gender as GenderID, GD.Gender,
	--FirstName +' '+ LastName as [Name], ---- > COMMENTED BY MURUGESH S
	ISNULL(FirstName + ' ', '') + ISNULL(LastName, '') AS [Name], ---> Added LINE BU MURUGESH S 
	RG.GuestType as GuestTypeID,CO.[ConfigValue] as GuestType,
		(SELECT D.DOB FROM guest.Guest G INNER JOIN contact.Details D ON G.ContactID=D.ContactID WHERE GuestID=RG.GuestID) AS DOB, RG.IsActive 
		FROM [reservation].[ReservationGuestMates] RG
		INNER JOIN [general].[Country] CT ON RG.Nationality = CT.CountryID
		INNER JOIN [person].[Gender] GD ON RG.Gender = GD.GenderID
		INNER JOIN [general].[Config] CO ON RG.GuestType = CO.ConfigID and CO.ConfigType =2
		where RG.ReservationID = @ReservationID

		--Get rate related fields		

	set @ExpectedCheckInDate =  (select ExpectedCheckIn from reservation.Reservation where ReservationID = @ReservationID)
	set @ExpectedCheckOutDate=  (select ExpectedCheckOut from reservation.Reservation where ReservationID = @ReservationID)

	--set @DateDifference=DATEDIFF(DAY,@ExpectedCheckInDate,GETDATE())
	--SELECT @RequiredReservationDeposit =  min(StandardReservationDepositPercent)  FROM  [reservation].[StandardReservationDeposit] 
	--		where  @DateDifference BETWEEN ReservationDayFrom and ReservationDayTo
	
	if(@ReservationID <@LastReservationID)
	begin  -- Old Query
	SELECT 
	--CASE WHEN rr.ReservationTypeID=10 then		
	--	RR.TotalAmountAfterTax -RR.TotalAmountAfterTax
	--ELSE
	--	RR.TotalAmountAfterTax
	--END AS TotalAmountAfterTax,
	
	CASE WHEN rr.ReservationTypeID=10 then
	 0 
	ELSE
	(SELECT isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)+ ISNULL(sum(AmtAfterTax),0)  from [account].[GuestLedgerDetails] where FolioNo=rr.FolioNumber  and ServiceId<>18)
	
	END AS TotalAmountAfterTax,

	RR.AdditionalDiscount, RR.AdditionalDiscountAmount,

	--CASE WHEN rr.ReservationTypeID=10 then
	--	isnull(CAST(RR.TotalPayable-RR.TotalPayable AS DECIMAL(18, 3)),0)  --Vivek - Rounding off to 3 decimals	
	--ELSE
	--	isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)  --Vivek - Rounding off to 3 decimals	
	--END AS TotalPayable
	CASE WHEN rr.ReservationTypeID=10 then
	 0 
	ELSE
	(SELECT isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)+ ISNULL(sum(AmtAfterTax),0)  from [account].[GuestLedgerDetails] where FolioNo=rr.FolioNumber  and ServiceId<>18)
	
	END AS TotalPayable
	--,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23) as [Advance],
	,(select isnull(sum(ActualAmount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID ) as [Advance], 
	
	--CASE WHEN rr.ReservationTypeID=10 then
	--	(select (RR.RequiredAMT - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)  --Vivek:- Here only Account type id 23(Advance Payment) is considered
	--ELSE
	--(select (RR.RequiredAMT - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)   --Vivek:- Here only Account type id 23(Advance Payment) is considered
	--END AS Balance,
	CASE
        WHEN RR.ReservationTypeID = 10 THEN 0
        ELSE
            ISNULL(CAST(RR.TotalPayable AS DECIMAL(18, 3)), 0) +
            ISNULL((SELECT SUM(GLD.AmtAfterTax)
                    FROM [account].[GuestLedgerDetails] AS GLD
                    WHERE GLD.FolioNo = RR.FolioNumber
                      AND GLD.ServiceId <> 18), 0) -
            ISNULL((SELECT SUM(ActualAmount)
                    FROM [account].[Transaction]
                    WHERE ReservationID = RR.ReservationID AND LocationID = RR.LocationID), 0)
    END AS Balance,
	CASE WHEN rr.ReservationTypeID=10 then
		(select (RR.TotalPayable - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)  --Vivek:- Here only Account type id 23(Advance Payment) is considered
	ELSE
	(select (RR.TotalPayable - isnull(sum(ActualAmount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)   --Vivek:- Here only Account type id 23(Advance Payment) is considered
	END AS FinalBalance	
	
	,isnull(CAST(RR.RequiredAMT AS DECIMAL(18, 3)),0) RequiredAMT --Vivek - Rounding off to 3 decimals
	
	from reservation.Reservation RR
	Left join [account].[Transaction] TR on RR.ReservationID = TR.ReservationID
	where RR.ReservationID= @ReservationID
	end
	else  -- New Query
	begin
	SELECT 
	
	CASE WHEN rr.ReservationTypeID=10 then
	 0 
	ELSE
	(SELECT isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)+ ISNULL(sum(AmtAfterTax),0)  from [account].[GuestLedgerDetails] where FolioNo=rr.FolioNumber  and ServiceId<>18)	
	END AS TotalAmountAfterTax,
	RR.AdditionalDiscount, RR.AdditionalDiscountAmount,	 
	CASE WHEN rr.ReservationTypeID=10 then
	 0 
	ELSE
	(SELECT isnull(CAST(RR.TotalPayable AS DECIMAL(18, 3)),0)+ ISNULL(sum(AmtAfterTax),0)  from [account].[GuestLedgerDetails] where FolioNo=rr.FolioNumber  and ServiceId<>18)	
	END AS TotalPayable
	,(select isnull(sum(Amount),0) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID ) as [Advance], 
	
	
	CASE
        WHEN RR.ReservationTypeID = 10 THEN 0
        ELSE
            ISNULL(CAST(RR.TotalPayable AS DECIMAL(18, 3)), 0) +
            ISNULL((SELECT SUM(GLD.AmtAfterTax)
                    FROM [account].[GuestLedgerDetails] AS GLD
                    WHERE GLD.FolioNo = RR.FolioNumber
                      AND GLD.ServiceId <> 18), 0) -
            ISNULL((SELECT SUM(Amount)
                    FROM [account].[Transaction]
                    WHERE ReservationID = RR.ReservationID AND LocationID = RR.LocationID), 0)
    END AS Balance,
	CASE WHEN rr.ReservationTypeID=10 then
		(select (RR.TotalPayable - isnull(sum(Amount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)  --Vivek:- Here only Account type id 23(Advance Payment) is considered
	ELSE
	(select (RR.TotalPayable - isnull(sum(Amount),0)) from [account].[Transaction] where ReservationID = RR.ReservationID and LocationID = RR.LocationID and AccountTypeID = 23)   --Vivek:- Here only Account type id 23(Advance Payment) is considered
	END AS FinalBalance	
	
	,isnull(CAST(RR.RequiredAMT AS DECIMAL(18, 3)),0) RequiredAMT --Vivek - Rounding off to 3 decimals
	
	from reservation.Reservation RR
	Left join [account].[Transaction] TR on RR.ReservationID = TR.ReservationID
	where RR.ReservationID= @ReservationID
	end
	
	-------------------------------------------------------------------


	IF(@ReservationStatusID = 2) --Canceled
		BEGIN
			SELECT 0.00 [TotalAmount]
			,0.00 [PayableAmount]
			,0.00 [DiscountAmount]
			,0.00 [OtherPayment]
			,0.00 [Advance]
			,0.00 [Balance]		
		END
	ELSE
		BEGIN
			SELECT fn.TotalAmount
			,fn.PayableAmount
			,fn.Discount [DiscountAmount]
			,fn.OtherPayment
			,fn.AdvancePay [Advance]
			,fn.Balance
			FROM [account].[fnGetReservationPayments_New](@ReservationID) fn	
		END

	SELECT @CurrencyID [CurrencyID]

	select distinct IT.ItemID,SC.Name,RM.RoomID,CONCAT(RM.RoomNo,'-',pr.RoomStatus)as RoomNo,Fl.[Floor], RM.Remarks,SC.SubCategoryID
	from [reservation].[Reservation] RS
	inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1 
	inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
	INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID  
	Inner join Products.RoomStatus pr ON Rm.RoomStatusID = pr.RoomStatusID 
	where RS.LocationID =@LocationID 
	and IT.ItemID in(select distinct ItemID from [reservation].[ReservationDetails] where ReservationID = @ReservationID)
	AND RM.RoomID not in  (SELECT roomid from Products.RoomLogs where  RoomStatusID not in (1,8) and IsPrimaryStatus=1 
		AND( 
		(Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(ToDate,'yyyy-MM-dd') > Format(@ExpectedCheckInDate,'yyyy-MM-dd')  AND Format(ToDate,'yyyy-MM-dd') < Format(@ExpectedCheckoutDate,'yyyy-MM-dd') ))   OR
         (Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')  AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <Format(ToDate,'yyyy-MM-dd') ))   OR																										
		((Format(fromdate,'yyyy-MM-dd') >Format(@ExpectedCheckInDate,'yyyy-MM-dd')   AND  Format(fromdate ,'yyyy-MM-dd') <  Format(@ExpectedCheckInDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR
		 ((Format(@ExpectedCheckInDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')   AND  Format(@ExpectedCheckInDate ,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR

		 
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') > Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd') )  OR
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') <Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >  Format(ToDate,'yyyy-MM-dd') )  OR 
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') ) OR
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   OR Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') )
		 )
		 
		 )
			
	order by SC.Name  ---ADDED BY MURUGESH S

	Select ISNULL(TaxRefNo,NULL) AS [TaxRefNo] from reservation.TaxExemptionDetails Where ReservationID=@ReservationID---Added Rajendra

	---------------------To Get Pickup booking details------------------
	 SELECT pickupdropid,[Type],PickupdropDate,PickUpDropTime,  PickupDropAddress,		  
		  CASE 
		  WHEN VehicleType =1 THEN 'Sedan'  
		  WHEN VehicleType =2 THEN 'SUV'  
		  WHEN VehicleType =3 THEN 'Station Wagon' 
		  WHEN VehicleType =4 THEN 'Hatchback'
		  END AS VehicleType,
		  pd.TobeCharge,		 
		  ISNull([complementary],0) as complementary,[FlightDetails],linetotalbt,pd.LineTotalTax
			FROM [Housekeeping].[PickupAndDrop] pd	WHERE PD.ReservationID=@ReservationID
			AND lower([Type]) in ('pickup','drop') and pd.Staus=1 

	
END





---------------------------------------------------------------------------------------


