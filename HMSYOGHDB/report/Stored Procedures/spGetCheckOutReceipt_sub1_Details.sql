CREATE PROCEDURE [report].[spGetCheckOutReceipt_sub1_Details] --438,1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int
)
AS
BEGIN
	SET NOCOUNT ON;

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 4)
	BEGIN
		DECLARE @FolioNumber varchar(20);
		DECLARE @ReservationDate varchar(11);
		DECLARE @ActualCheckIn varchar(11);
		DECLARE @ActualCheckOut varchar(11);
		DECLARE @ExpectedCheckIn varchar(11);
		DECLARE @ExpectedCheckOut varchar(11);		
		DECLARE @Bill varchar(120);
		DECLARE @Nights int;
		DECLARE @ActualStay int;	
		DECLARE @PhNO varchar(15);
		DECLARE @ReportAddress varchar(250);
		DECLARE @ReportLogo varchar(100);
		DECLARE @LocationName varchar(60);
		DECLARE @Rate DECIMAL(18,5);
		DECLARE @GuestID int;
		DECLARE @RateCurrencyID INT = (SELECT RateCurrencyID FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID AND IsActive = 1)
		
		SELECT @Rate = [ExchangeRate] 
		FROM currency.vwCurrentExchangeRate exr 
		WHERE exr.CurrencyID = @RateCurrencyID  AND exr.DrawerID = @DrawerID

		SELECT @FolioNumber = FolioNumber		
		,@ReservationID = ReservationID
		,@ActualCheckIn = FORMAT([ActualCheckIn],'dd-MMM-yyyy')
		,@ActualCheckOut = FORMAT([ActualCheckOut],'dd-MMM-yyyy')
		,@ExpectedCheckIn = FORMAT([ExpectedCheckIn],'dd-MMM-yyyy')
		,@ExpectedCheckOut = FORMAT([ExpectedCheckOut],'dd-MMM-yyyy')
		,@Bill = r.BillTo	
		,@ReservationDate = FORMAT([DateTime],'dd-MMM-yyyy hh:mm tt') 		
		,@Nights = Nights
		,@ActualStay = DATEDIFF(DAY, ActualCheckIn, ActualCheckOut)
		,@PhNO = r.PhoneNumber
		,@GuestID = GuestID
		FROM [reservation].[vwReservationDetails] r
		WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 4 --(Checked Out)

		SELECT @ReportAddress = [ReportAddress]
		,@ReportLogo = [ReportLogo]
		,@LocationName = LocationName
		FROM [general].[Location] 
		WHERE LocationID = @LocationID

		SELECT 
		CAST(fn.TotalAmount as decimal(18,2)) [TotalAmount]
		,CAST(fn.Discount as decimal(18,2)) [Discount] 
		,CAST(fn.VoidAmount as decimal(18,2)) [VoidAmount]
		,CAST(fn.Complimentary as decimal(18,2)) [ComplimentaryAmount]
		,CAST(fn.PayableAmount as decimal(18,2)) [PayableAmount]
		,CAST(fn.OtherPayment as decimal(18,2)) [OtherPayment]
		,CAST(fn.AdvancePay as decimal(18,2)) [Advance]
		,CAST(fn.TotalPayment as decimal(18,2)) [TotalPayment]
		,CAST(fn.Balance as decimal(18,2)) [Balance]
		,CASE WHEN @ActualStay <= 0 THEN 1 ELSE @ActualStay END [ActualStay]
		,@Nights [Nights]
		,CAST((SELECT reservation.fnGetKeyDepositAmount(@ReservationID, @GuestID)) as decimal(18,2)) [KeyDeposit]
		,CAST((SELECT reservation.fnGetKeyRefundAmount(@ReservationID, @GuestID)) as decimal(18,2)) [KeyRefund]
		,CAST((SELECT [reservation].[fnGetEarlyCheckOutExemptionAmount](@ReservationID, @GuestID)) as decimal(18,2)) [EarlyCheckOutExemption]
		,@FolioNumber [FolioNumber]
		,@ReservationID [ReservationID]
		,@ActualCheckIn [ActualCheckIn]
		,@ActualCheckOut [ActualCheckOut]
		,@ExpectedCheckIn [ExpectedCheckIn]
		,@ExpectedCheckOut [ExpectedCheckOut]
		,@Bill [BillTo]	
		,@PhNO [PhoneNumber]
		,@ReservationDate [ReservationDate]
		,FORMAT(GETDATE(),'dd-MMM-yyyy hh:mm tt') [Date]	
		,@ReportAddress [ReportAddress]
		,@ReportLogo [ReportLogo]
		,@LocationName [LocationName]
		,0.00 [Exemption]
		,@RateCurrencyID [RateCurrencyID]
		FROM [account].[fnGetReservationPayments](@ReservationID) fn	
	END
END
