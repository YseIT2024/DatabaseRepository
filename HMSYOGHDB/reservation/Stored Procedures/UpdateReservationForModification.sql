 
CREATE PROCEDURE [reservation].[UpdateReservationForModification]
( 
@ReservationID INT,
@GuestID                  INT,
@TitleID                  INT,
@FirstName                VARCHAR(100),
@LastName                 VARCHAR(100) = '',
@PhoneNumber              VARCHAR(15)= '',
@Email                    VARCHAR(100)= NULL,
@CountryID                INT,
@ReservationTypeID        INT,
@ReservationModeID        INT,
@ExpectedCheckIn          DATETIME,
@ExpectedCheckOut         DATETIME,
@Rooms                    INT,
@Adults                   INT,
@Children                 INT,
@Nights                   INT,
@Hold_TransactionModeID   INT,
@LocationID               INT,
@UserID                   INT,
@GroupCode                VARCHAR(20) = NULL,
@StaffNote                VARCHAR(max) = NULL,
@GuestNote                VARCHAR(max) = NULL,
@Remarks                  VARCHAR(max) = NULL,
@CompanyID                INT,
@CurrencyID               INT,
@TotalAmountBeforeTax     DECIMAL(18, 4),
@TotalTaxAmount           DECIMAL(18, 4),
@TotalAmountAfterTax      DECIMAL(18, 4),
@AdditionalDiscount       DECIMAL(18, 4),
@AdditionalDiscountAmount DECIMAL(18, 4),
@TotalPayable             DECIMAL(18, 4),
@OnlineReservationID      INT = NULL,
@BookedRefNo              VARCHAR(100) = NULL,
--Added Rajendra
@RequiredAMT DECIMAL(18, 6) = 0,
@dtReservationDetails AS [reservation].[RESERVATIONDETAILS] readonly,
@dtReservationTaxes AS [reservation].[RESERVATIONTAXES] readonly,
@CompanyTypeID           INT,
@ExAdults                INT,
@ExChildranJr            INT,
@ExChildranSr            INT,
@ApprovalForDiscount     BIT = NULL,
@ApprovalForSalesPrice   BIT = NULL,
@Status                  NVARCHAR(150)= NULL,
@Paid_Amount             DECIMAL(18, 6)= NULL,
@payment_Mode            NVARCHAR(100)= NULL,
@payment_Type            INT = NULL,
@AccountingDateID        INT = 0,
@NewroomId        INT = 0,
@SalesTypeID int=0,
@DiscountPercentage decimal(18,2)=0,
@dtAdvancePaymentSummary AS [account].[DTADVANCEPAYMENTBREAKUP] readonly ,
@CheckInRooms as [reservation].[CheckInRooms] readonly

)
AS
  BEGIN --SET XACT_ABORT ON will cause the transaction to be uncommittable
    --when the constraint violation occurs.
    SET xact_abort ON;
    DECLARE @IsSuccess BIT = 0;
    DECLARE @Message   VARCHAR(max) = '';
    DECLARE @ContactID INT;
    DECLARE @AddressID INT;
    --DECLARE @ReservationID int = 0;
    DECLARE @GenderID               INT;
	DECLARE @ReservationStatusID    INT =0;
	DECLARE @ItemID                 INT=0;
    DECLARE @AddressTypeID          INT = 1;
    DECLARE @DiscountID             INT = NULL;
    DECLARE @ReservedRoomID         INT;
    DECLARE @RoomID                 INT;
    DECLARE @Init                   INT = 1;
    DECLARE @ExtraChildren          INT;
    DECLARE @FolioNumbers           VARCHAR(100) = '';
    DECLARE @FolioNumber            INT;
    DECLARE @OutPutMSG              VARCHAR(500);
    DECLARE @DateDifference         INT
    DECLARE @ToUserIdDiscount       INT = NULL;
    DECLARE @ToUserIdSalesPrice     INT = NULL;
    DECLARE @ProcessTypeId          INT;
    DECLARE @GuestDateOfBirth       DATETIME;
    DECLARE @GuestType              INT = 9;
    DECLARE @ToUserIdAdvancePayment INT = NULL;
    DECLARE @Descripion             NVARCHAR(250);
    DECLARE @ComplementaryApproval  INT = 0;
	Declare @TodaysDate DateTime= Getdate();
	DECLARE @NotDesc             NVARCHAR(max) = '';
    IF(@ReservationTypeID = 10)
    BEGIN
      SET @ComplementaryApproval = 1
    END
    BEGIN try
      Set @ReservationStatusID= (SELECT ISNULL(ReservationStatusID,0)  FROM[reservation].[Reservation]  Where ReservationID=@ReservationID);
	  Set @ItemID= ( SELECT top 1 rd.itemid FROM   @dtReservationDetails rd);
	  Set @RoomID= (SELECT top 1 ISNULL(RoomID,0)  FROM[reservation].[ReservedRoom]  Where ReservationID=@ReservationID And IsActive=1);
      SET @Message = 'zero' ;  --TODO: Rservation creation is not working if we remove this line!!!!!!!!!
      IF @payment_Type = 1
      BEGIN
        SET @Hold_TransactionModeID = 8;
      END
      ELSE
      IF @payment_Type = 2
      BEGIN
        SET @Hold_TransactionModeID = 10;
      END
      ELSE
      IF @payment_Type = 3
      BEGIN
        SET @Hold_TransactionModeID = 9;
      END
      DECLARE @LocationCode VARCHAR(10) =
      (
             SELECT locationcode
             FROM   general.location
             WHERE  locationid = @LocationID );
      SET @DateDifference = Datediff( day, Getdate(), @ExpectedCheckIn )
      --SET @ExpectedCheckIn =(SELECT CONVERT( DATETIME, ( Format(@ExpectedCheckIn, 'yyyy-MM-dd') + ' ' +(SELECT [reservation].[Fngetstandardcheckintime]() ) ) ) );
      --SET @ExpectedCheckOut =(SELECT CONVERT( DATETIME, ( Format(@ExpectedCheckOut, 'yyyy-MM-dd') + ' ' + (SELECT [reservation].[Fngetstandardcheckouttime]() ) ) ) );
      SET @Nights = Datediff( day, @ExpectedCheckIn, @ExpectedCheckOut );
      SELECT @OutPutMSG = [room].[Checkifroomavailable] ( @ExpectedCheckIn, @ExpectedCheckOut, @dtReservationDetails )
      IF ( @OutPutMSG IS NOT NULL
      OR
      @OutPutMSG != '' )
      BEGIN
        SET @Message = @OutPutMSG;
        SET @IsSuccess = 0;
        --unsuccess
        SET @FolioNumbers = -2;
        --Insufficient vacant room
        --set @Message = 'First'
      END --set @Message = 'First1'
      ELSE
      BEGIN
        BEGIN TRANSACTION
        BEGIN
          SET @ContactID =(SELECT contactid FROM   guest.guest WHERE  guestid = @GuestID );
          SET @AddressID =(SELECT addressid FROM   contact.address WHERE  contactid = @ContactID AND    isdefault = 1 );
        END
        IF(@Message <> '')
        BEGIN
          SELECT @DiscountID = Isnull(d.[discountid], 0)          FROM   reservation.discount d          WHERE  d.[percentage] = @AdditionalDiscount
          IF( @DiscountID IS NULL          OR          @DiscountID = 0 )
          BEGIN
            SET @Message = Str(@AdditionalDiscount) + '% DISCOUNT'
            INSERT INTO [reservation].[discount]
                        ([percentage],[description]) 
						--VALUES(@AdditionalDiscount, CAST(@AdditionalDiscount as varchar(5)) + '% DISCOUNT')
                        VALUES(@AdditionalDiscount,Str(@AdditionalDiscount) + ' % DISCOUNT') --set @Message = '8'
            SET @DiscountID = Scope_identity();
          END
		  --Set @NotDesc= @NotDesc+ 'Reservation Has Been Modified  - '
		  if(@ReservationStatusID=1)
		  Begin
		  Set @NotDesc= @NotDesc+ 'Reservation With  status Reserved Has Been Modified  - '
		  end
		  if(@ReservationStatusID=12)
		  Begin
		  Set @NotDesc= @NotDesc+ 'Reservation With  status Requested Has Been Modified  - '
		  end

		  Set @NotDesc= @NotDesc+ (SELECT 
									  ' For [ReservationID] - '	+ ISNULL(Cast([ReservationID] AS nVarchar(50)),'')+
									  ', and  [FolioNumber] - '	+ ISNULL(Cast(FolioNumber AS nVarchar(50)),'')+
+Case When [ReservationTypeID]<>@ReservationTypeID Then ', [ReservationTypeID] From - '+ ISNULL(Cast([ReservationTypeID]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ReservationTypeID AS nVarchar(50)),'') Else '' End
+Case When [ReservationModeID]<>@ReservationModeID Then ', [ReservationModeID] From - '+ ISNULL(Cast([ReservationModeID]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ReservationModeID AS nVarchar(50)),'') Else '' End
+Case When [ExpectedCheckIn]<>@ExpectedCheckIn Then ', [ExpectedCheckIn] From - '+ ISNULL(Cast([ExpectedCheckIn]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ExpectedCheckIn AS nVarchar(50)),'') Else '' End
+Case When [ExpectedCheckOut]<>@ExpectedCheckOut Then ', [ExpectedCheckOut] From - '+ ISNULL(Cast([ExpectedCheckOut]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ExpectedCheckOut AS nVarchar(50)),'') Else '' End
+Case When [GuestID]<>@GuestID Then ', [GuestID] From - '+ ISNULL(Cast([GuestID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@GuestID AS nVarchar(50)),'') Else '' End
+Case When [Rooms]<>@Rooms Then ', [Rooms] From - '+ ISNULL(Cast([Rooms] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@Rooms AS nVarchar(50)),'') Else '' End
+Case When [Nights]<>@Nights Then ', [Nights] From - '+ ISNULL(Cast([Nights] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@Nights AS nVarchar(50)),'') Else '' End
+Case When [Adults]<>@Adults Then ', [Adults] From - '+ ISNULL(Cast([Adults]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@Adults AS nVarchar(50)),'') Else '' End
+Case When [Children]<>@Children Then ', [Children] From - '+ ISNULL(Cast([Children]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@Children AS nVarchar(50)),'') Else '' End
+Case When [Hold_TransactionModeID]<>@Hold_TransactionModeID Then ', [Hold_TransactionModeID] From - '+ ISNULL(Cast([Hold_TransactionModeID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@Hold_TransactionModeID AS nVarchar(50)),'') Else '' End
+Case When [LocationID]<>@LocationID Then ', [LocationID] From - '+ ISNULL(Cast([LocationID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@LocationID AS nVarchar(50)),'') Else '' End
+Case When [UserID]<>@UserID Then ', [UserID] From - '+ ISNULL(Cast([UserID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@UserID AS nVarchar(50)),'') Else '' End
+Case When [ReservationTypeID]<>@ReservationTypeID Then ', [DateTime] From - '+ ISNULL(Cast([DateTime] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ReservationTypeID AS nVarchar(50)),'') Else '' End
+Case When [CompanyID]<>@CompanyID Then ', [CompanyID] From - '+ ISNULL(Cast([CompanyID]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@CompanyID AS nVarchar(50)),'') Else '' End
+Case When [TotalAmountBeforeTax]<>@TotalAmountBeforeTax Then ', [TotalAmountBeforeTax] From - '+ ISNULL(Cast([TotalAmountBeforeTax] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@TotalAmountBeforeTax AS nVarchar(50)),'') Else '' End
+Case When [TotalTaxAmount]<>@TotalTaxAmount Then ', [TotalTaxAmount] From - '+ ISNULL(Cast([TotalTaxAmount]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@TotalTaxAmount AS nVarchar(50)),'') Else '' End
+Case When [TotalAmountAfterTax]<>@TotalAmountAfterTax Then ', [TotalAmountAfterTax] From - '+ ISNULL(Cast([TotalAmountAfterTax] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@TotalAmountAfterTax AS nVarchar(50)),'') Else '' End
+Case When [AdditionalDiscount]<>@AdditionalDiscount Then ', [AdditionalDiscount] From - '+ ISNULL(Cast([AdditionalDiscount] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@AdditionalDiscount AS nVarchar(50)),'') Else '' End
----+Case When [additionaldiscountamount]<>@AdditionalDiscountAmount Then ', [AdditionalDiscountAmount] From - '+ ISNULL(Cast([AdditionalDiscountAmount] AS nVarchar(50)),'')     + ' To - '  + ISNULL(Cast(@AdditionalDiscountAmount AS nVarchar(50)),'') Else '' End
--+Case When [totalpayable]<>@TotalPayable Then ', [TotalPayable] From - '+ ISNULL(Cast([TotalPayable]  AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@TotalPayable AS nVarchar(50)),'') Else '' End
+Case When [CurrencyID]<>@CurrencyID Then ', [CurrencyID] From - '+ ISNULL(Cast([CurrencyID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@CurrencyID AS nVarchar(50)),'') Else '' End
+Case When [RequiredAMT]<>@RequiredAMT Then ', [RequiredAMT] From - '+ ISNULL(Cast([RequiredAMT] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@RequiredAMT AS nVarchar(50)),'') Else '' End
+Case When [CompanyTypeID]<>@CompanyTypeID Then ', [CompanyTypeID] From - '+ ISNULL(Cast([CompanyTypeID] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@CompanyTypeID AS nVarchar(50)),'') Else '' End
+Case When [extrachildju]<>@ExChildranJr Then ', [ExtraChildJu] From - '+ ISNULL(Cast([ExtraChildJu] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ExChildranJr AS nVarchar(50)),'') Else '' End
+Case When [extrachildse]<>@ExChildranSr Then ', [ExtraChildSe] From - '+ ISNULL(Cast([ExtraChildSe] AS nVarchar(50)),'')    + ' To - '  + ISNULL(Cast(@ExChildranSr AS nVarchar(50)),'') Else '' End
 
 FROM [HMSYOGH].[reservation].[Reservation]
 Where [ReservationID]=@ReservationID )

          UPDATE [reservation].[reservation] SET    
				[reservationtypeid] = @ReservationTypeID,	[reservationmodeid] = @ReservationModeID,	[expectedcheckin] = @ExpectedCheckIn,
                 [expectedcheckout] = @ExpectedCheckOut,	[guestid] = @GuestID,						[rooms] = @Rooms,
                 [nights] = @Nights,						[adults] = @Adults,							[children] = @Children,
                 [hold_transactionmodeid] = @Hold_TransactionModeID,[locationid] = @LocationID,			[userid] = @UserID,
                 [datetime] = Getdate(),[companyid] = @CompanyID,[totalamountbeforetax] = @TotalAmountBeforeTax,
                 [totaltaxamount] = @TotalTaxAmount,[totalamountaftertax] = @TotalAmountAfterTax,                 [additionaldiscount] = @AdditionalDiscount,
                 [additionaldiscountamount] = @AdditionalDiscountAmount,                 [totalpayable] = @TotalPayable,                 [currencyid] = @CurrencyID,
                 [requiredamt] = @RequiredAMT,                 [companytypeid] = @CompanyTypeID,                 [extrachildju] = @ExChildranJr,
                 [extrachildse] = @ExChildranSr , [SalesTypeID]= @SalesTypeID
				 WHERE  reservationid = @ReservationID

		  
          SET    @Message = 'Reservation Updated Successfully.';          
          --SET @IsSuccess = 1;
          --success
         --Set @NotDesc= @NotDesc + @Message+ ' \r\n To  - '+ (SELECT top 10 
									--  '[ReservationID] - '	+ ISNULL(Cast([ReservationID] AS nVarchar(50)),'')
									--  +', [FolioNumber] - '+ ISNULL(Cast([FolioNumber]  AS nVarchar(50)),'')
									--  +', [ReservationTypeID] - '+ ISNULL(Cast([ReservationTypeID]  AS nVarchar(50)),'')
									--  +', [ReservationModeID] - '+ ISNULL(Cast([ReservationModeID]  AS nVarchar(50)),'')
									--  +', [ExpectedCheckIn] - '+ ISNULL(Cast([ExpectedCheckIn]  AS nVarchar(50)),'')
									--  +', [ActualCheckIn] - '+ ISNULL(Cast([ActualCheckIn]  AS nVarchar(50)),'')
									--  +', [ExpectedCheckOut] - '+ ISNULL(Cast([ExpectedCheckOut]  AS nVarchar(50)),'')
									--  +', [ActualCheckOut] - '+ ISNULL(Cast([ActualCheckOut]  AS nVarchar(50)),'')
									--  +', [GuestID] - '+ ISNULL(Cast([GuestID] AS nVarchar(50)),'')
									--  +', [Rooms] - '+ ISNULL(Cast([Rooms] AS nVarchar(50)),'')
									--  +', [Nights] - '+ ISNULL(Cast([Nights] AS nVarchar(50)),'')
									--  +', [Adults] - '+ ISNULL(Cast([Adults]  AS nVarchar(50)),'')
									--  +', [Children] - '+ ISNULL(Cast([Children]  AS nVarchar(50)),'')
									--  +', [ReservationStatusID] - '+ ISNULL(Cast([ReservationStatusID] AS nVarchar(50)),'')
									--  +', [Hold_TransactionModeID] - '+ ISNULL(Cast([Hold_TransactionModeID] AS nVarchar(50)),'')
									--  +', [LocationID] - '+ ISNULL(Cast([LocationID] AS nVarchar(50)),'')
									--  +', [UserID] - '+ ISNULL(Cast([UserID] AS nVarchar(50)),'')
									--  +', [DateTime] - '+ ISNULL(Cast([DateTime] AS nVarchar(50)),'')
									--  +', [CompanyID] - '+ ISNULL(Cast([CompanyID]  AS nVarchar(50)),'')
									--  +', [TotalAmountBeforeTax] - '+ ISNULL(Cast([TotalAmountBeforeTax] AS nVarchar(50)),'')
									--  +', [TotalTaxAmount] - '+ ISNULL(Cast([TotalTaxAmount]  AS nVarchar(50)),'')
									--  +', [TotalAmountAfterTax] - '+ ISNULL(Cast([TotalAmountAfterTax] AS nVarchar(50)),'')
									--  +', [AdditionalDiscount] - '+ ISNULL(Cast([AdditionalDiscount] AS nVarchar(50)),'')
									--  +', [AdditionalDiscountAmount] - '+ ISNULL(Cast([AdditionalDiscountAmount] AS nVarchar(50)),'')
									--  +', [TotalPayable] - '+ ISNULL(Cast([TotalPayable]  AS nVarchar(50)),'')
									--  +', [RoomChargeEffectDate] - '+ ISNULL(Cast([RoomChargeEffectDate] AS nVarchar(50)),'')
									--  +', [OnlineReservationID] - '+ ISNULL(Cast([OnlineReservationID]  AS nVarchar(50)),'')
									--  +', [CurrencyID] - '+ ISNULL(Cast([CurrencyID] AS nVarchar(50)),'')
									--  +', [RequiredAMT] - '+ ISNULL(Cast([RequiredAMT] AS nVarchar(50)),'')
									--  +', [ExtraAdults] - '+ ISNULL(Cast([ExtraAdults] AS nVarchar(50)),'')
									--  +', [CompanyTypeID] - '+ ISNULL(Cast([CompanyTypeID] AS nVarchar(50)),'')
									--  +', [ExtraChildJu] - '+ ISNULL(Cast([ExtraChildJu] AS nVarchar(50)),'')
									--  +', [ExtraChildSe] - '+ ISNULL(Cast([ExtraChildSe] AS nVarchar(50)),'')
									--  +', [AuthorizedFlag] - '+ ISNULL(Cast([AuthorizedFlag] AS nVarchar(50)),'')
									--  +', [BookedRefNo] - '+ ISNULL(Cast([BookedRefNo] AS nVarchar(50)),'')
									--  +', [SalesTypeID] - '+ ISNULL(Cast([SalesTypeID] AS nVarchar(50)),'')
								 -- FROM [HMSYOGH].[reservation].[Reservation]
									--Where [ReservationID]=@ReservationID )




		 DELETE          FROM   [reservation].[reservationdetails]          WHERE  reservationid = @ReservationID;
          
        -- INSERT INTO [reservation].[reservationdetails]
        --              (
        --                          [reservationid],[itemid],[nightdate],[rooms],
        --                          [adults],[extraadults],[children],[extrachildren],
        --                          [unitpricebeforediscount],[discount],[unitpriceafterdiscount],
        --                          [totaltax],[totaltaxamount],[unitpriceaftertax],[linetotal],extrachildrensr
        --              )
						  --SELECT @ReservationID,rd.itemid,rd.nightdate,rd.rooms,rd.adults,rd.extraadults,
								-- rd.children,rd.extrachildren,rd.unitpricebeforediscount,rd.discount,rd.unitpriceafterdiscount,								 rd.totaltax,rd.totaltaxamount,rd.unitpriceaftertax,rd.linetotal,rd.exchildsr
						  --FROM   @dtReservationDetails rd

							 ---------------------  Added On 26-01-2024 to update Summary
						  declare @tempTableDT table(							        [ReservationID] [int],									[DiscountPercentage][decimal](18,2),									[ItemID][int],
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
									[ExChildSr][int]
									)						   insert into @tempTableDT						   SELECT @ReservationID,@DiscountPercentage, * FROM @dtReservationDetails rd
						    
						
							INSERT INTO [reservation].[ReservationDetails]							([ReservationID],[ItemID],[NightDate],[Rooms],[Adults],[ExtraAdults],							[Children],[ExtraChildren],[UnitPriceBeforeDiscount],[Discount],[UnitPriceAfterDiscount],[TotalTax],							[TotalTaxAmount],[UnitPriceAfterTax],[LineTotal],ExtraChildrenSr,[DiscountPercentage])							select 							rd.ReservationID,rd.ItemID,rd.NightDate,							sum(rd.Rooms),rd.Adults,rd.ExtraAdults,							rd.Children,rd.ExtraChildren,rd.UnitPriceBeforeDiscount,							rd.Discount,rd.UnitPriceAfterDiscount,rd.TotalTax,							rd.TotalTaxAmount,rd.UnitPriceAfterTax,							case when @OnlineReservationID>0 then sum(rd.Rooms)*rd.LineTotal else rd.LineTotal end, 							rd.ExChildSr,							--case when Discount=0 then 0 else ((rd.Discount/rd.UnitPriceBeforeDiscount)*100) end							DiscountPercentage							FROM @tempTableDT  rd							group by 
							rd.ReservationID,rd.ItemID,rd.NightDate,--sum(rd.Rooms),							rd.Adults,rd.ExtraAdults,rd.Children,rd.ExtraChildren,							rd.UnitPriceBeforeDiscount,rd.Discount,rd.UnitPriceAfterDiscount,							rd.TotalTax,rd.TotalTaxAmount,rd.UnitPriceAfterTax,rd.LineTotal,rd.ExChildSr,DiscountPercentage							 
							 ---------------------  Added On 26-01-2024 to update Summary

							 UPDATE [reservation].[Reservation]							   SET 							   --TotalAmountBeforeTax= (select sum(r.UnitPriceBeforeDiscount)from [reservation].[ReservationDetails] r where r.ReservationID = @ReservationID),							   TotalAmountBeforeTax=(select Sum(r.LineTotal)-sum(TotalTaxAmount) from [reservation].[ReservationDetails]  r where r.ReservationID = @ReservationID),							   TotalTaxAmount=(select Sum(r.TotalTaxAmount) from [reservation].[ReservationDetails]  r where r.ReservationID = @ReservationID),							   TotalAmountAfterTax=(select Sum(r.LineTotal) from [reservation].[ReservationDetails]  r where r.ReservationID = @ReservationID),							   TotalPayable=(select Sum(r.LineTotal) from [reservation].[ReservationDetails]  r where r.ReservationID = @ReservationID),							   AdditionalDiscountAmount=(select Sum(r.Discount)   from [reservation].[ReservationDetails]  r where r.ReservationID = @ReservationID), AdditionalDiscount=@DiscountPercentage							   WHERE ReservationID = @ReservationID;

							 ------------------------------------------------------------------------------------------
                
         INSERT INTO [reservation].[reservationtaxdetails]
					 ([reservationid],[itemid],[taxid])
				SELECT @ReservationID,rt.itemid,rt.taxid FROM   @dtReservationTaxes rt
          
		  --SET @Message = 'ReservationDetails Updated Successfully.';
    --      SET @IsSuccess = 1;
          
		  --success
          IF(@StaffNote IS NOT NULL)
          BEGIN
            UPDATE [reservation].[note]
            SET    [note] = @StaffNote,[userid] = @UserID,[datetime] = Getdate() WHERE  [reservationid] = @ReservationID AND    [notetypeid] = 1
          END
          IF(@GuestNote IS NOT NULL)
          BEGIN
            UPDATE [reservation].[note] SET [note] = @GuestNote,[userid] = @UserID,[datetime] = Getdate() WHERE  [reservationid] = @ReservationID AND [notetypeid] = 3

			-----------Added By Somnath---------------------
			DECLARE @Acti VARCHAR(MAX) = 'Guest Comment has been Modified for the ReservationID- '+Cast(@ReservationID AS Varchar(20))+', FolioNo- '+Cast((Select FolioNumber From Reservation.Reservation Where ReservationID= @ReservationID) As Varchar(20))+' On date- '+Cast(GetDate() AS Varchar(20))+', By UserID- '+Cast(@UserID AS Varchar(20))
			--EXEC [app].[spInsertActivityLog]20,@LocationID,@Acti,@UserID, 'Guest Comment has been Modified'	
			-----------Added By Somnath---------------------
          END
          IF(@Remarks IS NOT NULL)
          BEGIN
            UPDATE [reservation].[note] SET [note] = @Remarks, [userid] = @UserID, [datetime] = Getdate() WHERE  [reservationid] = @ReservationID AND [notetypeid] = 4
          END
          SET @GuestDateOfBirth =  (SELECT  d.dob FROM guest.guest g 
		  INNER JOIN contact.details d ON   g.contactid = d.contactid WHERE      g.guestid = @GuestID )
          IF (@GuestDateOfBirth != '')
          BEGIN
            IF ( 12 > ( SELECT Datediff( year, @GuestDateOfBirth, Getdate() ) ) )
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
          END --Insert Main guest data into guestmate table
          SET @GenderID =(SELECT genderid FROM   person.title WHERE  titleid = @TitleID );          
		  
		  --DELETE FROM   [reservation].[reservationguestmates]
    --      WHERE  reservationid = @ReservationID and GuestID=@GuestID;
          
    --      INSERT INTO [reservation].[reservationguestmates]
    --                  (reservationid,firstname,middlename,lastname,gender,
				--	  dob,guesttype,nationality,actualcheckin,expectedcheckout,
				--	  actualcheckout,userid,createddate,isactive,guestid
    --                  )
    --                  VALUES
    --                  (@ReservationID,@FirstName,NULL,@LastName,@GenderID,
    --                              @GuestDateOfBirth,@GuestType,@CountryID,NULL,NULL,
				--					NULL,@UserID,Getdate(),1,@GuestID)
		
          
          --success
          --set @Message = '8'

          INSERT INTO [reservation].[reservationstatuslog]
                      ([reservationid],[reservationstatusid],[userid],[datetime],[remarks])
                      VALUES
                      (@ReservationID,1,@UserID,Getdate(),
					  'New reservation has been Updated. @ExpectedCheckIn -> ' + Format(@ExpectedCheckIn, 'dd-MMM-yyyy') + 
					  ' @ExpectedCheckOut -> ' + Format( @ExpectedCheckOut, 'dd-MMM-yyyy' ))
          SET @FolioNumbers = @FolioNumbers + ' ' + '<b>' + @LocationCode + CONVERT(VARCHAR, @FolioNumber) + '</b>' + ','
          SET @Init                         += 1;
	 
        if(@ReservationStatusID=1 ) --And @NewroomId>0)
		Begin
		
			--DELETE FROM [reservation].[RoomRate] 
			--WHERE ReservedRoomID = @ReservedRoomID AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

			--DELETE FROM guest.GuestWallet
			--WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');
												
			UPDATE [reservation].[ReservedRoom]
			SET	IsActive=0
			WHERE ReservationID=@ReservationID --and  RoomID = @RoomID	
			--UPDATE [reservation].[ReservedRoom]
			--SET 
			--RoomID=@NewRoomID,ExpectedCheckIn=@ExpectedCheckIn,ExpectedCheckOut=@ExpectedCheckOut,			
			--UserID = @UserID,ModifiedDate = GETDATE()
			--WHERE ReservationID=@ReservationID and  RoomID = @RoomID						
				
			--DECLARE @ExpectedCheckInID int = (CAST(FORMAT(@ExpectedCheckIn,'yyyyMMdd') as int));
			--DECLARE @ExpectedCheckOutID int = (CAST(FORMAT(@ExpectedCheckOut,'yyyyMMdd') as int));
				
			Delete From  [Products].[RoomLogs] Where [ReservationID] = @ReservationID 
			--UPDATE [Products].[RoomLogs] --[room].[RoomStatusHistory]
			--SET RoomID=@NewRoomID,
			--FromDateID=@ExpectedCheckInID,
			--ToDateID=@ExpectedCheckOutID,
			--FromDate=@ExpectedCheckIn,
			--ToDate=@ExpectedCheckOut,
			--CreatedBy = @UserID,
			--CreateDate=GETDATE()
			--WHERE [ReservationID] = @ReservationID AND RoomID = @RoomID --AND IsPrimaryStatus = 1

			Delete [reservation].[ReservedRoomLog] Where ReservationID=@ReservationID
			--Update [reservation].[ReservedRoomLog] set
			--roomid=@NewRoomID,
			--Date=GETDATE()
			--where ReservationID=@ReservationID and RoomID=@RoomID		

				 --IF NOT EXISTS (SELECT 1 FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID)
				BEGIN
					-- If no existing records, then proceed to insert
					INSERT INTO [reservation].[ReservedRoom] ([ReservationID], [RoomID], [StandardCheckInOutTimeID], [IsActive], [RateCurrencyID])
					SELECT @ReservationID, CR.RoomID, 1, 1, @CurrencyID
					FROM @CheckInRooms CR;

					--DECLARE @ExpectedCheckIn DATE;
					--DECLARE @ExpectedCheckOut DATE;

					SET @ExpectedCheckIn = (SELECT ExpectedCheckIn FROM reservation.Reservation WHERE ReservationID = @ReservationID);
					SET @ExpectedCheckOut = (SELECT ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID = @ReservationID);

					DECLARE @ExpectedCheckInID INT = (CAST(FORMAT(@ExpectedCheckIn, 'yyyyMMdd') AS INT));
					DECLARE @ExpectedCheckOutID INT = (CAST(FORMAT(@ExpectedCheckOut, 'yyyyMMdd') AS INT));

					INSERT INTO [Products].[RoomLogs]
					(
						[RoomID], [FromDateID], [ToDateID], [RoomStatusID], [IsPrimaryStatus],
						[FromDate], [ToDate], [ReservationID], [CreatedBy], [CreateDate]
					)
					SELECT
						RoomID, @ExpectedCheckInID, @ExpectedCheckOutID, 2, 1, @ExpectedCheckIn,
						@ExpectedCheckOut, @ReservationID, @UserID, GETDATE()
					FROM [reservation].[ReservedRoom]
					WHERE ReservationID = @ReservationID AND IsActive = 1;

					Insert into [reservation].[ReservedRoomLog] ( [ReservationID], [RoomID], [Date], [UserID] )
					Select @ReservationID, RoomID, GETDATE(), @UserID
					FROM [reservation].[ReservedRoom]
					WHERE ReservationID = @ReservationID AND IsActive = 1;

                    END
		End

		SET @Message = 'Reservation Updated Successfully.';
        SET @IsSuccess = 1;

        END
		
        COMMIT TRANSACTION
		EXEC [app].[spInsertActivityLog] 32,@LocationID,@NotDesc,@UserID	, @Message
      END

    END try
    BEGIN catch
      IF ( Xact_state() = -1 )
      BEGIN
        ROLLBACK TRANSACTION;
        SET @Message = Error_message();
        SET @IsSuccess = 0;
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Message,@UserID, @Message
        --error
        SET @FolioNumbers = -1;
        --error
      END;
    END catch;
    
	BEGIN 
      SELECT @IsSuccess     AS [IsSuccess],
             @Message       AS [Message],
             @FolioNumber   AS [FolioNumber],
             @ReservationID AS [ReservationID]
    END
  END