

CREATE FUNCTION [reservation].[fnGetReservationRoomBill]
(	
	@ReservationID int
)
RETURNS @Output TABLE ([TotalAmount] decimal(18,6),[DiscountAmount] decimal(18,6),[Nights] int,[ActualStay] int,[AvgRate] decimal(18,6)) 
AS
BEGIN	
	DECLARE @Nights int;	
	DECLARE @ActualStay int;
	DECLARE @TotalAmount decimal(18,6);	
	DECLARE @DiscountAmount decimal(18,6);	
	DECLARE @ActualCheckIn datetime;
	DECLARE @ReservationStatusID int;
	DECLARE @ValidDay int;

	SELECT @Nights = r.Nights
	,@ActualCheckIn = r.[ActualCheckIn]
	,@ReservationStatusID = r.ReservationStatusID	
	FROM reservation.Reservation r 	
	WHERE ReservationID = @ReservationID

	IF(@ReservationStatusID = 3) --IN-House
		BEGIN
			SET @ActualStay = (SELECT DATEDIFF(DAY, @ActualCheckIn, GETDATE()));
		END
	ELSE IF(@ReservationStatusID = 4) --Checked OUT
		BEGIN
			SET @ActualStay = (SELECT Nights FROM reservation.Reservation WHERE ReservationID = @ReservationID)
		END

	IF(@ActualStay <= 0 OR @ActualStay IS NULL)
	BEGIN
		SET @ActualStay = 1;
	END	

	SELECT @TotalAmount = SUM(rat.Rate), @ValidDay = COUNT(rat.ReservedRoomRateID) 
	FROM reservation.ReservedRoom rr	
	INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID 
	AND rr.IsActive = 1 AND rat.IsActive = 1 AND rat.IsVoid = 0
	WHERE rr.ReservationID = @ReservationID 

	SET @DiscountAmount = (SELECT[reservation].[fnGetReservationDiscountAmount](@ReservationID,NULL));

	INSERT INTO @Output 
	([TotalAmount], [DiscountAmount], [Nights], [ActualStay], [AvgRate])
	SELECT ISNULL(@TotalAmount,0), ISNULL(@DiscountAmount,0.00), @Nights, @ActualStay, ISNULL((@TotalAmount/@ValidDay),0)

	RETURN
END





