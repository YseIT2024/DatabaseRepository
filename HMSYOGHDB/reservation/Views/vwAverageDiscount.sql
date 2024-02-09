
CREATE VIEW [reservation].[vwAverageDiscount]
AS
	SELECT rr.ReservationID, ISNULL(AVG(d.[Percentage]),0) [AvgDiscount]
	FROM reservation.Reservation r
	INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rat.IsActive = 1 AND rat.IsVoid = 0
	LEFT JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	GROUP BY rr.ReservationID
