
CREATE FUNCTION [reservation].[fnGetReservationDiscountAmount]
(
	@ReservationID INT,
	@GuestID INT = NULL
)
RETURNS decimal(18,8)
AS
BEGIN
	DECLARE @TotalDiscount decimal(18,6);	
	
	SELECT @TotalDiscount = SUM(rat.Rate * d.[Percentage] / 100)
	FROM reservation.ReservedRoom rr
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rr.IsActive = 1
	INNER JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rat.IsVoid = 0

	RETURN CAST(ISNULL(@TotalDiscount,0) as decimal(18,3))
END




