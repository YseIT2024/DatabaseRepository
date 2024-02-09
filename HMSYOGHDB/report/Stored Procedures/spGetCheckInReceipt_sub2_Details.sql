CREATE PROCEDURE [report].[spGetCheckInReceipt_sub2_Details] --2380,1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 3)
	BEGIN
		DECLARE @FolioNumber varchar(20);
		DECLARE @ReservationDate varchar(11);		
		DECLARE @Bill varchar(120);
		DECLARE @Nights int;	
		DECLARE @PhNO varchar(15);
		DECLARE @ReportAddress varchar(250);
		DECLARE @ReportLogo varchar(100);
		DECLARE @LocationName varchar(60);
		DECLARE @Rate DECIMAL(18,5);
		DECLARE @GuestCountry varchar(30);
		DECLARE @ActualStay int;
		DECLARE @Address varchar(50);
		DECLARE @ExpectedCheckIn varchar(30);
		DECLARE @ActualCheckIn varchar(30);
		DECLARE @ExpectedCheckOut varchar(30);
		DECLARE @Adults int;
		DECLARE @Children int;
		DECLARE @GuestID int;
		DECLARE @CheckInTime VARCHAR(15) = (SELECT CONVERT(VARCHAR(5),StandardCheckInTime,108) + ' - ' + CONVERT(VARCHAR(5),StandardCheckInTimeCloseAt,108) FROM reservation.StandardCheckInOutTime)
    	DECLARE @CheckOutTime VARCHAR(15) = (SELECT 'until ' + CONVERT(VARCHAR(5),StandardCheckOutTime,108) FROM reservation.StandardCheckInOutTime)
		DECLARE @RateCurrencyID INT = (SELECT RateCurrencyID FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID AND IsActive = 1)
		
		SELECT @Rate = [ExchangeRate] 
		FROM currency.vwCurrentExchangeRate exr 
		WHERE exr.CurrencyID = @RateCurrencyID  AND exr.DrawerID = @DrawerID

		SELECT 
		@FolioNumber = FolioNumber
		,@ReservationID = ReservationID		
		,@GuestID = GuestID
		,@Bill = r.BillTo 		
		,@ReservationDate = FORMAT([DateTime],'dd-MMM-yyyy hh:mm tt') 		
		,@ActualStay = DATEDIFF(DAY, ActualCheckIn, ExpectedCheckOut)
		,@PhNO = r.PhoneNumber
		,@GuestCountry = CountryName
		,@Address = (CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END)
			+ (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END)	
		,@ExpectedCheckIn = FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') 
		,@ActualCheckIn = FORMAT([ActualCheckIn],'dd-MMM-yyyy') 	
		,@ExpectedCheckOut = FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') 
		,@Adults = Adults + ExtraAdults
		,@Children = Children
		FROM [reservation].[vwReservationDetails] r
		WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 3
		
		SELECT @ReportAddress = [ReportAddress]
		,@ReportLogo = [ReportLogo]
		,@LocationName = LocationName
		FROM [general].[Location] 
		WHERE LocationID = @LocationID

		SELECT CAST(fn.TotalAmount as decimal(18,2)) [TotalAmount]
		,CAST(fn.Discount as decimal(18,2)) [Discount] 
		,CAST(fn.VoidAmount as decimal(18,2)) [VoidAmount]
		,CAST(fn.Complimentary as decimal(18,2)) [ComplimentaryAmount]
		,CAST(fn.PayableAmount as decimal(18,2)) [PayableAmount]
		,CAST(fn.OtherPayment as decimal(18,2)) [OtherPayment]
		,CAST(fn.AdvancePay as decimal(18,2)) [Advance]
		,CAST(fn.TotalPayment as decimal(18,2)) [TotalPayment]
		,CAST(fn.Balance as decimal(18,2)) [Balance]
		,CAST((SELECT reservation.fnGetKeyDepositAmount(@ReservationID,@GuestID)) as decimal(18,2)) [KeyDeposit]
		,CAST((SELECT reservation.fnGetKeyRefundAmount(@ReservationID,@GuestID)) as decimal(18,2)) [KeyRefund]
		,@FolioNumber [FolioNumber]
		,@ReservationID [ReservationID]		
		,@Bill [BillTo]	
		,@PhNO [PhoneNumber]
		,@ReservationDate [ReservationDate]
		,FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') [Date]	
		,@ReportAddress [ReportAddress]
		,@ReportLogo [ReportLogo]
		,@LocationName [LocationName]
		,@GuestCountry [Country]
		,@Address [Address]
		,@ExpectedCheckIn [ExpectedCheckIn]
		,@ActualCheckIn [ActualCheckIn]
		,@ExpectedCheckOut [ExpectedCheckOut]
		,@ActualStay [Nights]
		,@Adults [Adults]
		,@Children [Children]
		,@CheckInTime [CheckInTime]
	    ,@CheckOutTime [CheckOutTime]
		,0.00 [Exemption]
		,@RateCurrencyID [RateCurrencyID]
		FROM [account].[fnGetReservationPayments](@ReservationID) fn	
	END	
END

