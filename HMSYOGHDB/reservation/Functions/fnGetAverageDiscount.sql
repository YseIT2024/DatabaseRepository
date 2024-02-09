
CREATE FUNCTION [reservation].[fnGetAverageDiscount]
(
	@ReservationID INT
)
RETURNS varchar(30)
AS
BEGIN
	DECLARE @Percentage decimal(18,2);		
	DECLARE @Discount varchar(30)
	
	SELECT @Percentage = AVG(d.[Percentage])
	FROM reservation.Reservation r  
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID 
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID 
	INNER JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	WHERE r.ReservationID = @ReservationID AND rr.IsActive = 1 AND rat.IsActive = 1 AND rat.IsVoid = 0

	SET @Discount = CAST(ISNULL(@Percentage,0) as varchar(8)) + '% avg discount';

	RETURN @Discount
END




