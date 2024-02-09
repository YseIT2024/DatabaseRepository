
CREATE FUNCTION [account].[fnGetReservationPayment]
(
	@ReservationID INT
)
RETURNS decimal(18,8)
AS
BEGIN
	DECLARE @OtherPayment decimal(18,6);	

	SELECT @OtherPayment = CAST(ISNULL(SUM(gw.Amount),0) as decimal(18,2))
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID 
	AND gw.AccountTypeID NOT IN (7,12,14,20,50,82,83,84,85)

	RETURN @OtherPayment
END





