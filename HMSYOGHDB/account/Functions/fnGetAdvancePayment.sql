
CREATE FUNCTION [account].[fnGetAdvancePayment]
(
	@ReservationID INT
)
RETURNS decimal(18,2)
AS
BEGIN
	DECLARE @Advance decimal(18,2);	

	SELECT @Advance = CAST(ISNULL(SUM(gw.Amount),0) as decimal(18,6))
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID 
	AND gw.AccountTypeID = 23

	RETURN @Advance
END

