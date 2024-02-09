CREATE Proc [guest].[spGetGuestFolio] --4738,3711,1,1,1,1
(	
	@ReservationID int,
	@GuestID int,
	@FolioType int,
	@DrawerID int,
	@LocationID int,
	@UserID int = null
)
AS
BEGIN
	SET NOCOUNT ON;
	--@FolioType = ALL = 1,
	--@FolioType = DEBIT = 2,
	--@FolioType = CREDIT = 3,
	--@FolioType = VOID = 4,
	--@FolioType = COMPLIMENT = 5

	DECLARE @Parameter VARCHAR(100) = (SELECT Value FROM [app].[Parameter] WHERE ParameterID = 3);
    DECLARE @Rate DECIMAL(18,5);
	DECLARE @IDs TABLE(ID int);
	DECLARE @RateCurrencyID INT = (SELECT RateCurrencyID FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID AND IsActive = 1);
	DECLARE @ActualStay int;
	DECLARE @ValidDay int; 
	DECLARE @ReservationTypeID int = (SELECT ReservationTypeID FROM reservation.Reservation WHERE ReservationID = @ReservationID);
	DECLARE @dtRooms TABLE([Date] nVARCHAR(11), RoomNo INT)

	DECLARE @CheckInTime VARCHAR(15) = 
		(SELECT CONVERT(VARCHAR(5),StandardCheckInTime,108) + ' - ' + CONVERT(VARCHAR(5),StandardCheckInTimeCloseAt,108) 
		FROM reservation.StandardCheckInOutTime);

	DECLARE @CheckOutTime VARCHAR(15) = 
		(SELECT 'until ' + CONVERT(VARCHAR(5),StandardCheckOutTime,108) 
		FROM reservation.StandardCheckInOutTime);
	
	IF(@FolioType = 1) --ALL
		BEGIN
			INSERT INTO @IDs
			SELECT gw.WalletID
			FROM Guest.GuestWallet gw
			WHERE gw.ReservationID = @ReservationID AND gw.GuestID = @GuestID
		END
	ELSE IF(@FolioType = 2) --DEBIT
		BEGIN
			INSERT INTO @IDs
			SELECT gw.WalletID
			FROM Guest.GuestWallet gw
			WHERE gw.ReservationID = @ReservationID AND gw.GuestID = @GuestID AND gw.Amount < 0
		END
	ELSE IF(@FolioType = 3) --CREDIT
		BEGIN
			INSERT INTO @IDs
			SELECT gw.WalletID
			FROM Guest.GuestWallet gw
			WHERE gw.ReservationID = @ReservationID AND gw.GuestID = @GuestID AND gw.Amount > 0
		END
	ELSE IF(@FolioType = 4) --Void
		BEGIN
			INSERT INTO @IDs
			SELECT gw.WalletID
			FROM Guest.GuestWallet gw
			WHERE gw.ReservationID = @ReservationID AND gw.GuestID = @GuestID AND gw.IsVoid = 1
		END	
		
	SELECT @Rate = [ExchangeRate] 
	FROM currency.vwCurrentExchangeRate exr 
	WHERE exr.CurrencyID = @RateCurrencyID  AND exr.DrawerID = @DrawerID

	SELECT @ActualStay = 
		CASE WHEN ReservationStatusID = 4 THEN DATEDIFF(DAY, ActualCheckIn, ActualCheckOut) 
		ELSE DATEDIFF(DAY, ActualCheckIn, ExpectedCheckOut) END
    FROM [reservation].[Reservation]
	WHERE ReservationID = @ReservationID AND LocationID = @LocationID

	SELECT @ValidDay = COUNT(rat.ReservedRoomRateID)
	FROM reservation.ReservedRoom rr
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID
	WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1

	DECLARE @ShiftedRoomNo int = 0;
			
	SELECT DISTINCT rw.[ReservationID]	
	,rw.FolioNumber
	,rw.ReservationStatusID
	,rw.[Adults] + rw.[ExtraAdults] [Adults]
	,rw.[Children]
	,CASE WHEN @ActualStay <= 0 THEN 1 ELSE @ActualStay END [Nights]
	,FORMAT([DateTime],'dd-MMM-yyyy') [ReservationDate]
	,rw.[Discount]
	,r.RoomID
	,r.RoomNo
	,rt.[RoomType]
	,CAST(ISNULL((CAST(payment.TotalAmount as decimal(18,2))/@ValidDay),0) as decimal(18,2)) [AvgRate]
	,CAST(payment.TotalAmount as decimal(18,2)) [TotalAmount]
	,CAST(payment.VoidAmount as decimal(18,2)) [VoidAmount]
	,CAST(payment.Complimentary as decimal(18,2)) [ComplimentaryAmount]
	,CAST(payment.Discount as decimal(18,2)) [DiscountAmount]
	,CAST(payment.PayableAmount as decimal(18,2)) [PayableAmount]
	,CAST(payment.OtherPayment as decimal(18,2)) [OtherPayment]
	,CAST(payment.AdvancePay as decimal(18,2)) [Advance]
	,CAST(payment.TotalPayment as decimal(18,2)) [TotalPayment]
	,CAST(payment.Balance as decimal(18,2)) [Balance]
	,CAST((SELECT [reservation].[fnGetKeyRefundAmount] (@ReservationID,@GuestID)) as decimal(18,2)) [KeyRefund]
	,rw.FullName AS [Name]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') [ExpectedCheckOut]
	,FORMAT([ActualCheckIn],'dd-MMM-yyyy HH:mm') [ActualCheckIn]	
	,CAST((SELECT [reservation].[fnGetKeyDepositAmount] (@ReservationID,@GuestID)) as decimal(18,2)) [KeyDeposit]
	,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END)
	+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address]	
	,FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt')[ReportDate]
	,rw.PhoneNumber [GuestPhNo]
	,(SELECT ReportAddress FROM general.Location WHERE LocationID = @LocationID) [ReportAddress]
	,(SELECT LocationName FROM general.Location WHERE LocationID = @LocationID) [LocationName]
	,rw.CountryName [Country]
	,@CheckInTime [CheckInTime]
	,@CheckOutTime [CheckOutTime]	
	,ISNULL(RoomChargeEffectDate,FORMAT([ActualCheckIn],'dd-MMM-yyyy'))	[RoomChargeEffectDate]
	,ISNULL(@ShiftedRoomNo,0) [ShiftedRoomNo]	
	,rw.CompanyID
	,@ReservationTypeID [ReservationTypeID]
	FROM [reservation].[vwReservationDetails] rw 
	INNER JOIN reservation.ReservedRoom rr ON rw.ReservationID = rr.ReservationID AND rr.IsActive = 1	
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](rw.ReservationID)) payment
	WHERE rw.ReservationID = @ReservationID AND rw.GuestID = @GuestID AND rw.LocationID = @LocationID   

	DECLARE @RoomNo int = 
	(
		SELECT TOP 1 r.RoomNo 
		FROM reservation.ReservedRoom rr
		INNER JOIN room.Room r ON rr.RoomID = r.RoomID 		
		WHERE rr.ReservationID = @ReservationID AND  rr.IsActive = 1
	);

	INSERT INTO @dtRooms([Date], [RoomNo])
	SELECT FORMAT(d.Date, 'dd-MMM-yyyy'),  r.RoomNo 
	FROM reservation.ReservedRoom rr
	INNER JOIN reservation.RoomRate rt ON rr.ReservedRoomID = rt.ReservedRoomID
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID 		
	INNER JOIN general.[Date] d ON rt.DateID = d.DateID
	WHERE rr.ReservationID = @ReservationID

	SELECT [WalletID]   
	,gf.AccountTypeID
	,ISNULL(r.[RoomNo],@RoomNo) [RoomNo]
	,[AccountType]
	,gf.[Date]
	,[AccountingDate]
	,CAST([Debit] as decimal(18,2)) [Debit]
	,CAST([Credit] as decimal(18,2)) [Credit]
	,[Void]	
	,CASE WHEN IsVoid = 1 THEN CONCAT([Remarks],'(Void)') ELSE [Remarks] END [Remarks]
	,IsVoid
	,@Parameter [Parameter]
	,gf.[ServiceID]
	,gf.[TransactionID]
	FROM [guest].[vwGuestFolio] gf
	INNER JOIN @IDs t ON gf.WalletID = t.ID
	LEFT JOIN @dtRooms r ON gf.[Date] = r.[Date]
	ORDER BY [WalletID]	

	SELECT @RateCurrencyID [RateCurrencyID]

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Guest Folio', @UserID
END

