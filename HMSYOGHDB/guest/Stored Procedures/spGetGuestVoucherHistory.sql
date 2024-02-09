
CREATE PROCEDURE [guest].[spGetGuestVoucherHistory] 
(	
	@VoucherID int,
	@DrawerID int = null,
	@UserID int = null
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReservationID int;
	DECLARE @ActualStay int;
	DECLARE @GuestID int;

	DECLARE @LocationID INT = NULL;

	IF(@DrawerID IS NOT NULL)
		SET @LocationID = 
		(
			Select LocationID From app.Drawer Where DrawerID = @DrawerID
		);

	SELECT @ActualStay = DATEDIFF(DAY, ActualCheckIn, ActualCheckOut)
	,@ReservationID = v.ReservationID
	,@GuestID = v.GuestID
    FROM guest.Voucher v
	INNER JOIN reservation.Reservation r ON v.ReservationID = r.ReservationID
	WHERE v.VoucherID = @VoucherID

	EXEC [guest].[spGetGuestVoucherHistory_Sub1] @ActualStay, @ReservationID, @GuestID
	EXEC [guest].[spGetGuestVoucherHistory_Sub2] @ReservationID
	EXEC [guest].[spGetGuestVoucherHistory_Sub3] @VoucherID

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Guest Voucher History', @UserID
END

