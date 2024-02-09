CREATE PROCEDURE [account].[spGetReservationPayment]
(
	@ReservationID int,
	@DrawerID int = 0
)
AS
BEGIN	
	SET NOCOUNT ON;	

	SELECT CAST(ISNULL(SUM(gw.Amount),0) as decimal(18,2)) [OtherPayment]
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID AND gw.AccountTypeID NOT IN (7,12,14,20,50,82,83,84,85)
END










