CREATE FUNCTION [reservation].[fnGetKeyDepositAmount]
(
	@ReservationID INT,
	@GuestID INT
)
RETURNS decimal(18,8)
AS
BEGIN
	DECLARE @TotalAmount decimal(18,2);	
	
	SELECT @TotalAmount = SUM(gw.Amount)
	FROM [guest].[GuestWallet] gw
	WHERE gw.ReservationID = @ReservationID
	AND gw.GuestID = @GuestID
	AND gw.IsVoid = 0	
	AND gw.AccountTypeID = 50

	RETURN ISNULL(@TotalAmount,0.00)
END



