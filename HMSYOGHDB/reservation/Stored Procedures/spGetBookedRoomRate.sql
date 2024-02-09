
CREATE PROCEDURE [reservation].[spGetBookedRoomRate] --634 
(
	@ReservationID INT
)
AS
BEGIN	
	SELECT
	rat.ReservedRoomID
	,rat.ReservedRoomRateID
	,rat.[DateID]
	,FORMAT(d.[Date],'dd-MMM-yyyy') [Date]
	,[RateID]
	,CAST([Rate] - (dsc.[Percentage] * [Rate] / 100) as decimal(18,2)) [Rate]
	,CAST((dsc.[Percentage] * [Rate] / 100) as decimal(18,2)) [Discount]
	,[IsVoid] 
	FROM reservation.ReservedRoom rr
	INNER JOIN [reservation].[RoomRate] rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rr.IsActive = 1
	INNER JOIN general.[Date] d ON rat.DateID = d.DateID
	INNER JOIN reservation.Discount dsc ON rat.DiscountID = dsc.DiscountID 
	WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 
END




