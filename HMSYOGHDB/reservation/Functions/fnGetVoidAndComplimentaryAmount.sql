


CREATE FUNCTION [reservation].[fnGetVoidAndComplimentaryAmount]
(	
	@ReservationID int
)
RETURNS @Output TABLE([VoidAmount] decimal(18,6), [ComplimentaryAmount] decimal(18,6)) 
AS
BEGIN		
	DECLARE @VoidAmount decimal(18,6);	
	DECLARE @ComplimentaryAmount decimal(18,6);
	DECLARE @AccountTypeID int = 20;
	

	SELECT @VoidAmount = SUM(gw.Amount-((d.Percentage/100)*gw.Amount))
	FROM guest.GuestWallet gw
	INNER JOIN reservation.RoomRate rt ON gw.ReservedRoomRateID = rt.ReservedRoomRateID
	INNER JOIN reservation.Discount d ON rt.DiscountID = d.DiscountID
	WHERE gw.ReservationID = @ReservationID AND gw.IsVoid = 1

	SELECT @ComplimentaryAmount = SUM(gw.Amount)
	FROM guest.GuestWallet gw
	WHERE gw.ReservationID = @ReservationID AND gw.AccountTypeID = @AccountTypeID
	
	INSERT INTO @Output 
	([VoidAmount], [ComplimentaryAmount])
	SELECT ABS(ISNULL(@VoidAmount,0)), ABS(ISNULL(@ComplimentaryAmount,0))

	RETURN
END




