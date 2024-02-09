 
create PROCEDURE [reservation].[CreateReservationForNewGuest_New_BackUp_24012024]
(	
	@GuestID int,
	@TitleID int, 
	@FirstName varchar(100),
	@LastName varchar(100) = '',	
	@PhoneNumber varchar(15)='',
	@Email varchar(100)=Null,
	@CountryID int,		
	@ReservationTypeID int,
	@ReservationModeID int,
	@ExpectedCheckIn datetime,
	@ExpectedCheckOut datetime,	
	@Rooms int,
	@Adults int,
	@Children int,
	@Nights int,	
	@Hold_TransactionModeID int,		
	@LocationID int,
	@UserID int,	
	@GroupCode varchar(20) = NULL,		
	@StaffNote varchar(max) = NULL,
	@GuestNote varchar(max) = NULL,
	@Remarks varchar(max) = NULL,	
	@CompanyID int,
	@CurrencyID int,
	@TotalAmountBeforeTax decimal(18, 4),
	@TotalTaxAmount  decimal(18, 4),
	@TotalAmountAfterTax decimal(18, 4),
	@AdditionalDiscount decimal(18, 4),
	@AdditionalDiscountAmount decimal(18, 4),
	@TotalPayable decimal(18, 4),
	@OnlineReservationID int = NULL,
	@BookedRefNo varchar(100) = NULL,--Added Rajendra
	@RequiredAMT decimal(18, 6) = 0,
	@dtReservationDetails as [reservation].[ReservationDetails] readonly,
	@dtReservationTaxes as [reservation].[ReservationTaxes] readonly,
	@CompanyTypeID int,

	@ExAdults int,
	@ExChildranJr int,
	@ExChildranSr int,
	@ApprovalForDiscount bit=null,
	@ApprovalForSalesPrice bit=null,


	@Status  nvarchar(150)=null,
	@Paid_Amount decimal(18,6)=null,
	@payment_Mode nvarchar(100)=null,
	@payment_Type int=null,
	@AccountingDateID INT=0,
	@SalesTypeID int=0,
	@dtAdvancePaymentSummary as [account].[dtAdvancePaymentBreakup] readonly
	--@dtdtReservationGuestInfos as [reservation].[dtReservationGuestInfos] readonly
	
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ContactID int;
	DECLARE @AddressID int;
	DECLARE @ReservationID int = 0;
	DECLARE @GenderID int;	
	DECLARE @AddressTypeID int = 1;
	DECLARE @DiscountID int = NULL;
	DECLARE @ReservedRoomID int;
	DECLARE @RoomID int;
	DECLARE @Init int = 1;
	DECLARE @ExtraChildren int;
	DECLARE @FolioNumbers VARCHAR(100) = '';
	DECLARE @FolioNumber int;
	DECLARE @OutPutMSG varchar(500);
	Declare @DateDifference int

	DECLARE @ToUserIdDiscount INT=NULL;
	DECLARE @ToUserIdSalesPrice INT=NULL;
	DECLARE @ProcessTypeId INT;
	DECLARE @GuestDateOfBirth DATETIME;
	DECLARE @GuestType INT=9;
	DECLARE @ToUserIdAdvancePayment INT=NULL;
	declare @Descripion NVARCHAR(250);
 
 DECLARE @ComplementaryApproval int=0;
 IF(@ReservationTypeID=10)
 BEGIN
	set @ComplementaryApproval=1
 END

	BEGIN TRY
	
	set @Message = 'zero' --TODO: Rservation creation is not working if we remove this line!!!!!!!!!
	

IF @payment_Type = 1
BEGIN
	SET @Hold_TransactionModeID = 8;
END
ELSE IF @payment_Type = 2
BEGIN
	SET @Hold_TransactionModeID = 10;
END
ELSE IF @payment_Type = 3
BEGIN
	SET @Hold_TransactionModeID = 9;
END



		DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);		
		SET @DateDifference=DATEDIFF(DAY,GETDATE(),@ExpectedCheckIn)
		

		--SET @ExpectedCheckIn = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckIn,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckInTime]()))));
		
	
		--SET @ExpectedCheckOut = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckOut,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckOutTime]()))));

		if CAST(@ExpectedCheckIn AS TIME)= CAST('00:00:00' AS TIME)
		BEGIN
		SET @ExpectedCheckIn = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckIn,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckInTime]()))));
		END
		IF CAST(@ExpectedCheckOut as TIME)= CAST('00:00:00' AS TIME)
		BEGIN
		SET @ExpectedCheckOut = (SELECT CONVERT(DATETIME, (FORMAT(@ExpectedCheckOut,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckOutTime]()))));
		END


		SET @Nights = DATEDIFF(DAY,@ExpectedCheckIn,@ExpectedCheckOut);

		
		SELECT @OutPutMSG =  [room].[CheckIfRoomAvailable] (@ExpectedCheckIn,@ExpectedCheckOut,@dtReservationDetails)
	
		if (@OutPutMSG is not null or @OutPutMSG != '')
		BEGIN		
			SET @Message = @OutPutMSG ;
			SET @IsSuccess = 0; --unsuccess
			SET @FolioNumbers = -2; --Insufficient vacant room
			--set @Message = 'First'
		END
		--set @Message = 'First1'
		ELSE
			BEGIN			
				BEGIN TRANSACTION							
					IF(@GuestID=0)
						BEGIN	
						
						--set @Message = '2'
							--IF EXISTS(Select ContactID from [contact].[Address] where (PhoneNumber = @PhoneNumber AND @PhoneNumber != '') or (Email = @Email AND @Email <> NULL))
								IF EXISTS(Select ca.ContactID from [contact].[Address] ca
								 inner join [contact].[Details] cd on ca.ContactID=cd.ContactID
								 where cd.FirstName=@FirstName and (PhoneNumber = @PhoneNumber AND @PhoneNumber != '') or (Email = @Email AND @Email <> NULL))
								
								BEGIN
									SET @ContactID = (Select TOP 1 d.ContactID from [contact].[Address] ad
									INNER JOIN [contact].[Details] d ON ad.ContactID = d.ContactID
									WHERE d.FirstName=@FirstName and (ad.PhoneNumber = @PhoneNumber Or Email = @Email))
									
									IF @ContactID IS NULL
										BEGIN
											SET @Message = 'Phone Number already exists. Please Enter another number.';
											SET @IsSuccess = 0; --unsuccess
											SET @FolioNumbers = -3; --Invalid Phone Number
										END
									ELSE
										BEGIN	
											--UPDATE [contact].[Details] SET 
											--[LastName] = @LastName
											--WHERE ContactID = @ContactID								
												
											SET @GuestID = (SELECT GuestID FROM [guest].[Guest] WHERE ContactID = @ContactID)
										END							
								END
							ELSE
								BEGIN	
								--set @Message = '3'
									SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

									INSERT INTO [contact].[Details]
									([TitleID],[FirstName],[LastName],[GenderID])
									VALUES(@TitleID,@FirstName,@LastName,@GenderID)
								
									SET @ContactID = SCOPE_IDENTITY();
									
									INSERT INTO [contact].[Address]
									([AddressTypeID],[ContactID],[CountryID],[PhoneNumber],[Email],[IsDefault])
									VALUES(@AddressTypeID,@ContactID,@CountryID,ISNULL(@PhoneNumber,''),ISNULL(@Email,''),1)
									
									INSERT INTO [guest].[Guest]
									([ContactID],[GroupCode])
									VALUES(@ContactID,@GroupCode)
									
									SET @GuestID = SCOPE_IDENTITY();
								END							
						END
					ELSE
						BEGIN
						--set @Message = '4'
							SET @ContactID = (SELECT ContactID FROM guest.Guest WHERE GuestID = @GuestID);
							SET @AddressID = (SELECT AddressID FROM contact.Address WHERE ContactID = @ContactID AND IsDefault = 1);
										
							IF @PhoneNumber != ''
							BEGIN
							--set @Message = '5'
								UPDATE [contact].[Address]
								SET [PhoneNumber] = @PhoneNumber					
								WHERE AddressID = @AddressID
							END	
							
						END

					--IF (@ContactID IS NOT NULL)
					--BEGIN		
					IF(@Message <> '')
					BEGIN
					--set @Message = '6'
						SELECT @DiscountID = ISNULL( d.[DiscountID],0)
						FROM reservation.Discount d
						WHERE d.[Percentage] = @AdditionalDiscount
						--set @Message = str(@AdditionalDiscount)
						
						IF(@DiscountID IS NULL or @DiscountID =0)

						BEGIN
						set @Message =  str(@AdditionalDiscount) + '% DISCOUNT'
							INSERT INTO [reservation].[Discount]
							([Percentage], [Description])
							--VALUES(@AdditionalDiscount, CAST(@AdditionalDiscount as varchar(5)) + '% DISCOUNT')
							VALUES(@AdditionalDiscount, str(@AdditionalDiscount) + ' % DISCOUNT')
							--set @Message = '8'  
							SET @DiscountID = SCOPE_IDENTITY();
						END										
														
							--SET @FolioNumber = (SELECT [reservation].[fnGenerateFolioNumber](@LocationID)); -- Folio number will be created whilst confirmation
							SET @FolioNumber = 0;
							--set @Message = '7a'
							---For Online reservation do calculate required amount here
							--IF(@OnlineReservationID > 0)
							--	BEGIN
							--		SELECT @RequiredAMT =  min(StandardReservationDepositPercent)  FROM  [reservation].[StandardReservationDeposit] 
							--		where  @DateDifference >=ReservationDayFrom and @DateDifference <=ReservationDayTo
							--		SET @RequiredAMT = ((@TotalPayable * isnull(@RequiredAMT,0))/100)
							--	END
							------------------
							
							if(@Hold_TransactionModeID=1)
							Begin

							INSERT INTO [reservation].[Reservation]
							([ReservationTypeID],[ReservationModeID],[ExpectedCheckIn],[ExpectedCheckOut],[GuestID],
							[Rooms],[Nights],[Adults],[Children],[ReservationStatusID],
							[Hold_TransactionModeID],[UserID],[DateTime],[LocationID],[FolioNumber],
							[CompanyID],[TotalAmountBeforeTax],[TotalTaxAmount],[TotalAmountAfterTax],[AdditionalDiscount],
							[AdditionalDiscountAmount],[TotalPayable],[OnlineReservationID],[CurrencyID],[RequiredAMT],
							[CompanyTypeID],ExtraChildJu,ExtraChildSe,ExtraAdults,BookedRefNo,SalesTypeID)
							VALUES(@ReservationTypeID,@ReservationModeID,@ExpectedCheckIn,@ExpectedCheckOut,@GuestID,
							@Rooms,@Nights,@Adults,@Children,12,
							@Hold_TransactionModeID,@UserID,GETDATE(),@LocationID,@FolioNumber,
							@CompanyID,@TotalAmountBeforeTax,@TotalTaxAmount,@TotalAmountAfterTax,@AdditionalDiscount,
							@AdditionalDiscountAmount,@TotalPayable,@OnlineReservationID,@CurrencyID,@RequiredAMT,
							@CompanyTypeID,@ExChildranJr,@ExChildranSr,@ExAdults,@BookedRefNo,@SalesTypeID)--Added Rajendra
							
							SET @ReservationID = SCOPE_IDENTITY();	
						--	INSERT INTO [dbo].[TestTable] ([ColumnName]) VALUES('11')
							End
							ELSE
							IF NOT EXISTS(Select OnlineReservationID From [reservation].[Reservation] where OnlineReservationID=@OnlineReservationID)
							BEGIN

							
						
							INSERT INTO [reservation].[Reservation]
							([ReservationTypeID],[ReservationModeID],[ExpectedCheckIn],[ExpectedCheckOut],[GuestID],
							[Rooms],[Nights],[Adults],[Children],[ReservationStatusID],
							[Hold_TransactionModeID],[UserID],[DateTime],[LocationID],[FolioNumber],
							[CompanyID],[TotalAmountBeforeTax],[TotalTaxAmount],[TotalAmountAfterTax],[AdditionalDiscount],
							[AdditionalDiscountAmount],[TotalPayable],[OnlineReservationID],[CurrencyID],[RequiredAMT],
							[CompanyTypeID],ExtraChildJu,ExtraChildSe,ExtraAdults,BookedRefNo,SalesTypeID)
							VALUES(@ReservationTypeID,@ReservationModeID,@ExpectedCheckIn,@ExpectedCheckOut,@GuestID,
							@Rooms,@Nights,@Adults,@Children,12,
							@Hold_TransactionModeID ,@UserID,GETDATE(),@LocationID,@FolioNumber,
							@CompanyID,@TotalAmountBeforeTax,@TotalTaxAmount,@TotalAmountAfterTax,@AdditionalDiscount,
							@AdditionalDiscountAmount,@TotalPayable,@OnlineReservationID,@CurrencyID,@RequiredAMT,
							@CompanyTypeID,@ExChildranJr,@ExChildranSr,@ExAdults,@BookedRefNo,@SalesTypeID)--Added Rajendra

							SET @ReservationID = SCOPE_IDENTITY();

							--INSERT INTO [dbo].[TestTable] ([ColumnName]) VALUES('22')
							END
							ELSE 
							BEGIN
							 SET @IsSuccess = 0; 
						     SET @Message = 'Already reservation Exist';	
							END
							
							
							--INSERT INTO [reservation].[ReservationDetails]
							--([ReservationID],[ItemID],[NightDate],[Rooms],[Adults],[ExtraAdults],[Children],[ExtraChildren],[UnitPriceBeforeDiscount],
							-- [Discount],[UnitPriceAfterDiscount],[TotalTax],[TotalTaxAmount],[UnitPriceAfterTax],[LineTotal],ExtraChildrenSr,[DiscountPercentage])
							-- SELECT @ReservationID, rd.ItemID,rd.NightDate,rd.Rooms,rd.Adults,rd.ExtraAdults,rd.Children,rd.ExtraChildren,
							-- rd.UnitPriceBeforeDiscount,rd.Discount,rd.UnitPriceAfterDiscount,rd.TotalTax,rd.TotalTaxAmount,rd.UnitPriceAfterTax,rd.LineTotal,rd.ExChildSr,case when Discount=0 then 0 else ((Discount/rd.UnitPriceBeforeDiscount)*100) end
							-- FROM @dtReservationDetails rd	

							declare @tempTableDT table(							        [ReservationID] [int],									[ItemID][int],
									[NightDate][date],
									[Rooms][int],
									[Adults][int],
									[ExtraAdults][int],
									[Children][int],
									[ExtraChildren][int],
									[UnitPriceBeforeDiscount][decimal](18,2),
									[Discount][decimal](18,2),
									[UnitPriceAfterDiscount][decimal](18,2),
									[TotalTax][decimal](18,2),
									[TotalTaxAmount][decimal](18,2),
									[UnitPriceAfterTax][decimal](18,2),
									[LineTotal][decimal](18,2),
									[ExChildSr][int])
						   						   insert into @tempTableDT						   SELECT @ReservationID, * FROM @dtReservationDetails rd
						    
						
							INSERT INTO [reservation].[ReservationDetails]							([ReservationID],[ItemID],[NightDate],[Rooms],[Adults],[ExtraAdults],							[Children],[ExtraChildren],[UnitPriceBeforeDiscount],[Discount],[UnitPriceAfterDiscount],[TotalTax],							[TotalTaxAmount],[UnitPriceAfterTax],[LineTotal],ExtraChildrenSr,[DiscountPercentage])							select 							rd.ReservationID,rd.ItemID,rd.NightDate,							sum(rd.Rooms),rd.Adults,rd.ExtraAdults,							rd.Children,rd.ExtraChildren,rd.UnitPriceBeforeDiscount,							rd.Discount,rd.UnitPriceAfterDiscount,rd.TotalTax,							rd.TotalTaxAmount,rd.UnitPriceAfterTax,							case when @OnlineReservationID>0 then sum(rd.Rooms)*rd.LineTotal else rd.LineTotal end, 							rd.ExChildSr,							case when Discount=0 then 0 else ((rd.Discount/rd.UnitPriceBeforeDiscount)*100) end							FROM @tempTableDT  rd							group by 
							rd.ReservationID,rd.ItemID,rd.NightDate,--sum(rd.Rooms),							rd.Adults,rd.ExtraAdults,rd.Children,rd.ExtraChildren,							rd.UnitPriceBeforeDiscount,rd.Discount,rd.UnitPriceAfterDiscount,							rd.TotalTax,rd.TotalTaxAmount,rd.UnitPriceAfterTax,rd.LineTotal,rd.ExChildSr							 

							 ------------------------------------------------------------------------------------------
							 INSERT INTO [reservation].[ReservationTaxDetails]
							 ([ReservationID],[ItemID],[TaxID])
							 SELECT @ReservationID, rt.ItemID,rt.TaxID
							 FROM @dtReservationTaxes rt

							 -- INSERT INTO [reservation].[ReservationStatusLog]
							 --([ReservationID],ReservationStatusID,Remarks,UserID,DateTime,ReservedRoomRateID)
							 --VALUES (@ReservationID,12,
						

							IF(@StaffNote IS NOT NULL)
							BEGIN
								INSERT INTO [reservation].[Note]
								([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
								VALUES(1,@ReservationID,@StaffNote,@UserID,GETDATE())
							END
							
							IF(@GuestNote IS NOT NULL)
							BEGIN

								INSERT INTO [reservation].[Note]
								([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
								VALUES(3,@ReservationID,@GuestNote,@UserID,GETDATE())
								-----------Added By Somnath---------------------
								DECLARE @Acti VARCHAR(MAX) = 'New Guest Comment has been added for the ReservationID- '+Cast(@ReservationID AS Varchar(20))+', FolioNo- '+Cast((Select FolioNumber From Reservation.Reservation Where ReservationID= @ReservationID) As Varchar(20))+' On date- '+Cast(GetDate() AS Varchar(20))+', By UserID- '+Cast(@UserID AS Varchar(20))
					            EXEC [app].[spInsertActivityLog]20,@LocationID,@Acti,@UserID, 'New Guest Comment has been added'	
								-----------Added By Somnath---------------------
							END
							
							IF(@Remarks IS NOT NULL)
							BEGIN
								INSERT INTO [reservation].[Note]
								([NoteTypeID],[ReservationID],[Note],[UserID],[DateTime])
								VALUES(4,@ReservationID,@Remarks,@UserID,GETDATE())
							END


							SET @GuestDateOfBirth=(select d.DOB from guest.Guest g inner join contact.Details d on g.ContactID=d.ContactID where g.GuestID=@GuestID)
							IF (@GuestDateOfBirth!='')
								BEGIN
									IF (12>(select DATEDIFF(YEAR, @GuestDateOfBirth, GETDATE())))
										BEGIN
											SET @GuestType = 10
										END
										ELSE
										BEGIN
											SET @GuestType = 9
										END
								END
							ELSE
							 BEGIN
								 SET @GuestType = 9
							 END

							--Insert Main guest data into guestmate table
							SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);
							INSERT INTO [reservation].[ReservationGuestMates] ( ReservationID, FirstName, MiddleName, 
																   LastName, Gender, DOB, GuestType, Nationality, 
																   /*PIDType,PIDNo,*/ ActualCheckIn, ExpectedCheckOut, ActualCheckOut, 
																   UserID, CreatedDate, IsActive,GuestID)
										Values( @ReservationID, @FirstName, NULL, @LastName, @GenderID, @GuestDateOfBirth, @GuestType, ---(9 = Adult 10 = Child)
												  @CountryID, /*@PIDTypeID, @PIDNo,*/ NULL, NULL, NULL, @UserID, GetDate(), 1,@GuestID)
						   
							--set @Message = '8'
							INSERT INTO [reservation].[ReservationStatusLog]
							([ReservationID],[ReservationStatusID],[UserID],[DateTime], [Remarks])
							VALUES(@ReservationID, 1, @UserID, GETDATE(), 'New reservation has been accepted. @ExpectedCheckIn -> ' + FORMAT(@ExpectedCheckIn,'dd-MMM-yyyy') + ' @ExpectedCheckOut -> ' + FORMAT(@ExpectedCheckOut,'dd-MMM-yyyy'))
							
							SET @FolioNumbers = @FolioNumbers + ' ' + '<b>' + @LocationCode + CONVERT(VARCHAR,@FolioNumber) + '</b>' + ','
							SET @Init += 1;	

							
							IF(@ReservationTypeID =11)
							BEGIN

							INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
									(select @ReservationID, @CompanyTypeID,ServiceTypeID , CASE WHEN ServiceTypeID = 18 THEN 100 ELSE 0 END, @ReservationTypeID,'Company'
									FROM Service.Type WHERE IsActive = 1);

							INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
									(select @ReservationID, @GuestID,ServiceTypeID , CASE WHEN ServiceTypeID = 18 THEN 0 ELSE 100 END, 0,'Guest'
									FROM Service.Type WHERE IsActive = 1);

							END

							IF(@ReservationTypeID=1)
							BEGIN

							INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
									(select @ReservationID, @GuestID,ServiceTypeID , 100, 0,'Guest'
									FROM Service.Type WHERE IsActive = 1);

							END

							IF(@ReservationTypeID  > 1 )
							BEGIN
								IF(@ReservationTypeID  !=11 )
								BEGIN
									if (@CompanyTypeID !=null or @CompanyTypeID>0)
									begin
									--set @CompanyTypeID=(select companytypeid from reservation.reservation where reservationid=@ReservationID)
									INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
									(select @ReservationID, @CompanyTypeID,ServiceTypeID ,CASE WHEN ServiceTypeID = 18 THEN 100 ELSE 0 END, @ReservationTypeID,'Company'
									FROM Service.Type WHERE IsActive = 1);
									end				

									INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
									(select @ReservationID, @GuestID,ServiceTypeID , CASE WHEN ServiceTypeID = 18 THEN 0 ELSE 100 END, 0,'Guest'
									FROM Service.Type WHERE IsActive = 1);
								END
							END

							----------------To take co-guest from online booking----------
								--DECLARE @MinGuestNo INT
								--DECLARE @MaxGuestNo INT 
								--SELECT  @MinGuestNo= min(PK_TableA_ID) , @MaxGuestNo = max(PK_TableA_ID) 
								--FROM TableA

								--IF EXISTS(Select ca.ContactID from [contact].[Address] ca
								--	inner join [contact].[Details] cd on ca.ContactID=cd.ContactID
								--	where cd.FirstName=@FirstName and (PhoneNumber = @PhoneNumber AND @PhoneNumber != '') or (Email = @Email AND @Email <> NULL))
								
								--	BEGIN
								--	SET @ContactID = (Select TOP 1 d.ContactID from [contact].[Address] ad
								--	INNER JOIN [contact].[Details] d ON ad.ContactID = d.ContactID
								--	WHERE d.FirstName=@FirstName and (ad.PhoneNumber = @PhoneNumber Or Email = @Email))									
								--	IF @ContactID IS NOT NULL
								--		BEGIN
								--			SET @GuestID = (SELECT GuestID FROM [guest].[Guest] WHERE ContactID = @ContactID)											
											
								--		END							
								--	END
								--ELSE
								--	BEGIN	
								
								--	SET @GenderID = (SELECT GenderID FROM person.Title WHERE TitleID = @TitleID);

								--	INSERT INTO [contact].[Details]
								--	([TitleID],[FirstName],[LastName],[GenderID])
								--	VALUES(@TitleID,@FirstName,@LastName,@GenderID)
								
								--	SET @ContactID = SCOPE_IDENTITY();
									
								--	INSERT INTO [contact].[Address]
								--	([AddressTypeID],[ContactID],[CountryID],[PhoneNumber],[Email],[IsDefault])
								--	VALUES(@AddressTypeID,@ContactID,@CountryID,ISNULL(@PhoneNumber,''),ISNULL(@Email,''),1)
									
								--	INSERT INTO [guest].[Guest]
								--	([ContactID],[GroupCode])
								--	VALUES(@ContactID,@GroupCode)
									
								--	SET @GuestID = SCOPE_IDENTITY();
								--END	



							--------------------End-------------------------------------------
							
						--END
				
						IF(@Status='SUCCEEDED')
			BEGIN
			EXEC [reservation].[OnlinePaymentsResponse] @ReservationID,0,@Status,'',@payment_Type,@Paid_Amount
			END

						SET @FolioNumbers = LEFT(@FolioNumbers, LEN(@FolioNumbers)-1)
						
						SET @Message = (SELECT [guest].[fnGetGuestFullName](@GuestID));
						
						SET @IsSuccess = 1; --success
						SET @Message = 'New reservation has been created successfully for <b>' + @Message + '</b>';	
						--SET @Message = 'New reservation has been accepted successfully' ;	
					
						DECLARE @Title varchar(200) = 'New Reservation has been created for: ' + @FirstName + '@ ' + @LastName + '(' + CONVERT(VARCHAR,@FolioNumber) + ')' + ' With ReservationID-  '+ CAST(@ReservationID as varchar(10)) + ' And Folio No-  '+  (SELECT CONCAT(@LocationCode, FolioNumber) FROM reservation.Reservation WHERE ReservationID = @ReservationID) + ' has been completed successfully. '
						
						DECLARE @NotDesc varchar(max) = @Title + ' at ' + @LocationCode + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));

						EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
						 
						EXEC [app].[spInsertActivityLog]20,@LocationID,@NotDesc,@UserID,@Title	 -- Added By Somnath

						--- Insert Approval WorkFlow
						set @Descripion = @FirstName + ' ' + @LastName 
						IF (@ApprovalForDiscount=1)
							BEGIN
								SET @ProcessTypeId=2;
								SET @ToUserIdDiscount=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId  AND IsPrimary=1 ORDER BY ApprovalLevel ASC)
								
								EXEC [reservation].[spCreateUpdateAppravalForTransaction]@ProcessTypeId, @LocationID, @UserID, @ReservationID, 0, NULL, NULL, @ToUserIdDiscount, NULL,@Descripion
							END
						IF (@ApprovalForSalesPrice=1)
							BEGIN
								SET @ProcessTypeId=1;
								SET @ToUserIdSalesPrice=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId  AND IsPrimary=1 ORDER BY ApprovalLevel ASC)

								EXEC [reservation].[spCreateUpdateAppravalForTransaction] @ProcessTypeId, @LocationID, @UserID, @ReservationID, 0, NULL, NULL, @ToUserIdSalesPrice, NULL,@Descripion
							END
						--IF (@CompanyID=2) -- ID=2 FOR COMPANY
						--	BEGIN
						--		SET @ProcessTypeId=5;
						--		SET @ToUserIdAdvancePayment=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId  AND IsPrimary=1 ORDER BY ApprovalLevel ASC)
						--		IF(@ReservationTypeID=1)
						--			BEGIN
						--				DECLARE @CompanyName NVARCHAR(100)= (select CompanyName from [guest].[GuestCompany] where CompanyID=@CompanyTypeID)
						--				DECLARE @TitleName NVARCHAR(100)=(SELECT Title FROM [person].[Title] WHERE TitleID=@TitleID)
						--				SET @Descripion = 'Approval Pending  for ('+ CONCAT(@TitleName,' ', @FirstName , ' ', @LastName,'), (', @CompanyName,')')
						--			END
									 
						--		EXEC [reservation].[spCreateUpdateAppravalForTransaction] @ProcessTypeId, @LocationID, @UserID, @ReservationID, 0, NULL, NULL, @ToUserIdAdvancePayment, NULL,@Descripion
						--	END
						IF (@ComplementaryApproval=1) 
							BEGIN
								SET @ProcessTypeId=6;
								SET @ToUserIdAdvancePayment=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId  AND IsPrimary=1 ORDER BY ApprovalLevel ASC)
								DECLARE @Company NVARCHAR(100)= (select CompanyName from [guest].[GuestCompany] where CompanyID=@CompanyTypeID)

								DECLARE @TitleMr NVARCHAR(100)=(SELECT Title FROM [person].[Title] WHERE TitleID=@TitleID)

								if @CompanyID>1-- is not null 
								begin
								SET @Descripion = 'Approval Pending  for ('+ CONCAT(@TitleMr,' ', @FirstName , ' ', @LastName,'), (', @Company,')')
								end
								else 
								begin
								SET @Descripion = 'Approval Pending  for ('+ CONCAT(@TitleMr,' ', @FirstName , ' ', @LastName,')')
								end
								EXEC [reservation].[spCreateUpdateAppravalForTransaction] @ProcessTypeId, @LocationID, @UserID, @ReservationID, 0, NULL, NULL, @ToUserIdAdvancePayment, NULL,@Descripion
							
							END
						
						IF (@SalesTypeID=2)-- Credit Customer and Company  --(@CompanyID=2) -- ID=2 FOR COMPANY
							BEGIN
								SET @ProcessTypeId=7;
								SET @ToUserIdAdvancePayment=(SELECT TOP(1) UserId FROM [reservation].[ApprovalWorkflow] WHERE ProcessTypeId=@ProcessTypeId  AND IsPrimary=1 ORDER BY ApprovalLevel ASC)

								IF(@ReservationTypeID=1)
									BEGIN
										--DECLARE @CompanyName1 NVARCHAR(100)= (select CompanyName from [guest].[GuestCompany] where CompanyID=@CompanyTypeID)
										DECLARE @TitleName1 NVARCHAR(100)=(SELECT Title FROM [person].[Title] WHERE TitleID=@TitleID)
										SET @Descripion = 'Approval Pending  for ('+ CONCAT(@TitleName1,' ', @FirstName , ' ', @LastName,')')
									END
								ELSE
									BEGIN
										DECLARE @CompanyName NVARCHAR(100)= (select CompanyName from [guest].[GuestCompany] where CompanyID=@CompanyTypeID)
										DECLARE @TitleName NVARCHAR(100)=(SELECT Title FROM [person].[Title] WHERE TitleID=@TitleID)
										SET @Descripion = 'Approval Pending  for ('+ CONCAT(@TitleName,' ', @FirstName , ' ', @LastName,'), (', @CompanyName,')')
									END
									 
								EXEC [reservation].[spCreateUpdateAppravalForTransaction] @ProcessTypeId, @LocationID, @UserID, @ReservationID, 0, NULL, NULL, @ToUserIdAdvancePayment, NULL,@Descripion
							END

			--IF(@Status='SUCCEEDED')
			--BEGIN
			--EXEC [reservation].[OnlinePaymentsResponse] @ReservationID,0,@Status,'',@payment_Type,@Paid_Amount
			--END
	
	if(@ReservationID>0)
	begin
		DECLARE @OutputSequenceNo VARCHAR(255);
		--SET @AUTOID=(SELECT ISNULL(MAX(ProformaInvoiceId),1) FROM  [reservation].[ProformaInvoice])
		EXEC [report].spGetReportSequenceNo @DocTypeId = 1, @SequenceNo = @OutputSequenceNo OUTPUT;

		INSERT INTO [reservation].[ProformaInvoice](
		[DocumentTypeId]
		,[ReservationId]
		,[ProformaInvoiceNo]
		,[CreatedDate]
		,[CreatedBy])
		VALUES
		(1,@ReservationID,@OutputSequenceNo,GETDATE(),@UserID)
	end



								END	
							COMMIT TRANSACTION


						END		
				END TRY  
				BEGIN CATCH    
					IF (XACT_STATE() = -1) 
					BEGIN  			
						ROLLBACK TRANSACTION;  
						SET @Message = ERROR_MESSAGE();
						SET @IsSuccess = 0; --error
						SET @FolioNumbers = -1; --error
					END;  
		
					---------------------------- Insert into activity log---------------	
					DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
					EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID, @Message	
				END CATCH;  

				BEGIN
				--SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumbers AS [FolioNumber],@ReservationID as [ReservationID]
				SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumber AS [FolioNumber], @ReservationID as [ReservationID]
				END
				


			END
