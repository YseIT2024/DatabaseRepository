
create FUNCTION [account].[fnGetReservationPayments_New]
(	
	@ReservationID int
)
RETURNS @Output TABLE([TotalAmount] decimal(18,6), [Complimentary] decimal(18,6), [VoidAmount] decimal(18,6), [PayableAmount] decimal(18,6), [Discount] decimal(18,6)
                      ,[AdvancePay] decimal(18,6), [OtherPayment] decimal(18,6),[TotalPayment] decimal(18,6),[Balance] decimal(18,6)) 
AS
BEGIN
	DECLARE @TotalAmount decimal(18,6);
	DECLARE @Complimentary decimal(18,6) =0;
	DECLARE @ServiceAmount decimal(18,6) =0;
	DECLARE @VoidAmount decimal(18,6)=0;
	DECLARE @PayableAmount decimal (18,6);
	DECLARE @Discount decimal(18,6);
	DECLARE @Advance decimal(18,6);
	DECLARE @OtherPayment decimal(18,6);
	DECLARE @TotalPayment decimal(18,6);
	DECLARE @Balance decimal(18,6);
	DECLARE @TotalServiceRate decimal;
	
	SELECT @TotalAmount = TotalPayable
	FROM [reservation].[Reservation]
	WHERE ReservationID = @ReservationID 

	--SELECT @ServiceAmount = ABS(ISNULL(SUM(gw.Amount),0))
	--FROM guest.GuestWallet gw
	--WHERE gw.ReservationID = @ReservationID AND gw.AccountTypeID = 28

	select @TotalServiceRate = sum(ServiceRate) from [reservation].[ReservationServices] where ReservationID = 6058 and [Status] = 'A'

	--SET @TotalAmount = ISNULL((@TotalAmount + @ServiceAmount),0);
	SET @TotalAmount = ISNULL((@TotalAmount + @TotalServiceRate),0);

	--SELECT @VoidAmount = ISNULL(SUM(rat.Rate),0)
	--FROM reservation.ReservedRoom rr
	--INNER JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID --AND rr.IsActive = 1
	--INNER JOIN reservation.Discount d ON rat.DiscountID = d.DiscountID
	--WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rat.IsVoid = 1

	--SELECT @Complimentary = ISNULL(SUM(gw.Amount),0)
	--FROM guest.GuestWallet gw
	--WHERE gw.ReservationID = @ReservationID AND gw.AccountTypeID = 20

	SET @PayableAmount = ISNULL((@TotalAmount - ISNULL(@VoidAmount,0) - @Complimentary),0);

	--SELECT @Advance = ISNULL(SUM(gw.Amount),0)
	--FROM guest.GuestWallet gw
	--WHERE gw.ReservationID = @ReservationID 
	--AND gw.AccountTypeID = 23

	SELECT @Advance = ISNULL(SUM(Amount),0)
	FROM [account].[Transaction]
	WHERE ReservationID = @ReservationID 
	AND AccountTypeID = 23  --Advance

	--SELECT @OtherPayment = ISNULL(SUM(gw.Amount),0)
	--FROM guest.GuestWallet gw
	--WHERE gw.ReservationID = @ReservationID AND gw.AccountTypeID NOT IN (7,12,14,20,23,28,50,82,83,84,85)

	SELECT @OtherPayment = ISNULL(SUM(Amount),0)
	FROM [account].[Transaction]
	WHERE ReservationID = @ReservationID AND AccountTypeID NOT IN (7,12,14,20,23,28,50,82,83,84,85)

	SET @TotalPayment = ISNULL((@OtherPayment + @Advance),0);
	SET @Balance = ISNULL((@PayableAmount - @TotalPayment),0);
	
	INSERT INTO @Output
	(TotalAmount, VoidAmount, Complimentary, Discount, PayableAmount, AdvancePay, OtherPayment, TotalPayment, Balance)
	SELECT ISNULL(@TotalAmount,0), ISNULL(@VoidAmount,0), ISNULL(@Complimentary,0), ISNULL(@Discount,0), ISNULL(@PayableAmount,0), ISNULL(@Advance,0)
	,ISNULL(@OtherPayment,0), ISNULL(@TotalPayment,0), ISNULL(@Balance,0)

	RETURN
END
