CREATE PROC [reservation].[usp_ReservationCardNew_Select] --'1',9308,77,1,1
	@DocumentType varchar(16),
    @ReservationId int = null,
    @UserID int,    
	@LocationID int,
	@DrawerID int 
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @LocationCode VARCHAR(10);
	DECLARE @CardNo int=0;
			
	BEGIN TRY
		Select @CardNo=isnull(max(CardNo),0) + 1 from [reservation].[ReservationCard] where [DocumentType]=@DocumentType

			--select max(cardno) + 1 from [reservation].[ReservationCard] where [DocumentType]='Form'
			if @CardNo=0 or @CardNo =NULL
				BEGIN
					set @CardNo=1
				END
		BEGIN TRANSACTION		

			INSERT INTO [reservation].[ReservationCard]
						([CardNo],[DocumentType],[ReservationID],[LocationID],[CreatedBy],[CreatedOn])
					VALUES
						(@CardNo, @DocumentType, @ReservationId, @LocationID,@UserID,getdate())		

				SET @IsSuccess = 1; --success 
				SET @Message = 'Card Number Added';			  
	  
		COMMIT TRANSACTION
    
	SELECT @CardNo as CardNo

    if(@DocumentType ='1')
		Begin
		
    SELECT  RR.ReservationID [ReservationID]
	,CASE WHEN RR.FolioNumber > 0 THEN  LTRIM(STR(RR.FolioNumber)) ELSE 'N/A' END [FolioNumber]
	,[ReservationStatus]
	,ReservationMode
	,CASE WHEN ActualCheckIn IS NULL THEN '' ELSE FORMAT([ActualCheckIn],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckIn]
	,CASE WHEN ActualCheckOut IS NULL THEN '' ELSE FORMAT([ActualCheckOut],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckOut]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn]	
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut]	
	,FORMAT(RR.[DateTime],'dd-MMM-yyyy hh:mm tt') AS [DateTime]
	,CD.FirstName  as [Name]  
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
	,CASE WHEN RR.CompanyID =1 THEN 'Guest' ELSE (Select CompanyName from [guest].[GuestCompany] where CompanyID=RR.CompanyTypeID) END AS BillTo --Added by Arabinda on 21 Aug 23

	,EC.EmrContactName
	,EC.EmrContactNumber
	,EC.EmrContactRelation
	,RN.Note as ReservationRemarks -- reservation Remarks
	,RR.OnlineReservationID
	,GC.CountryName
	,FORMAT([DOB],'dd-MMM-yyyy') AS [DOB],
	CA.PhoneNumber
	,CD.LastName
	,CA.ZipCode
	,CA.City
	,(select [reservation].[fnGetReserveredRoom](@ReservationId)) as RoomNos
	,(select top(1) ISNULL(GuestSignature,'') from reservation.GuestSignature where InvoiceNo=@ReservationId and GuestSignatureTypeID=2) as CardSignatures
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
	left  join [reservation].[Note] RN on RR.ReservationID = RN.ReservationID and NoteID = 4
	left join [contact].[EmergencyContact] EC on RR.ReservationID = EC.ReservationID
	WHERE RR.ReservationID = @ReservationId
	
   END
			

	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
			
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = '';
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH; 	

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message] 
END




