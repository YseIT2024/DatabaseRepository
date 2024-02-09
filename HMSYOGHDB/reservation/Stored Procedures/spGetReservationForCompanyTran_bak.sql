Create PROCEDURE [reservation].[spGetReservationForCompanyTran_bak]
(	
	@FolioNo varchar(20),
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReservationID int;
	DECLARE @RateCurrencyID int;
	DECLARE @RoomNo int;
	DECLARE @RoomType varchar(30);

	SELECT @ReservationID = r.ReservationID, @RateCurrencyID = RateCurrencyID
	FROM reservation.Reservation r
	INNER JOIN reservation.ReservedRoom rm ON r.ReservationID = rm.ReservationID
	WHERE r.LocationID = @LocationID AND r.CompanyID > 0 AND r.ReservationStatusID IN (3,4)
	AND r.FolioNumber = CAST(STUFF(@FolioNo, 1, 3, '') as int)
	
	;WITH Room_cte
	as
	(
		SELECT TOP 1 r.RoomNo, rt.RoomType
		FROM reservation.ReservedRoom rr
		INNER JOIN room.Room r ON rr.RoomID = r.RoomID	
		INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID
		WHERE rr.ReservationID = @ReservationID AND  rr.IsActive = 1
	)
	SELECT @RoomNo = Room_cte.RoomNo, @RoomType = Room_cte.RoomType
	FROM Room_cte

	SELECT v.ReservationID
	,@RoomNo RoomNo
	,@RoomType RoomType
	,FORMAT(ISNULL(v.ActualCheckIn,v.[ExpectedCheckIn]), 'dd-MMM-yyyy') CheckIn
	,FORMAT(ISNULL(v.ActualCheckOut,v.[ExpectedCheckOut]), 'dd-MMM-yyyy') CheckOut
	,v.FullName
	,fn.TotalAmount
	,fn.DiscountAmount
	,vdcomp.ComplimentaryAmount Compliment
	,vdcomp.VoidAmount VoidAmount
	,(SELECT [account].[fnGetReservationPayment](@ReservationID)) OtherPayment
	,v.BillTo
	,v.CompanyID
	,@RateCurrencyID RateCurrencyID
	FROM [reservation].[vwReservationDetails] v		
	CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](v.ReservationID))vdcomp
	CROSS APPLY (SELECT * FROM [reservation].[fnGetReservationRoomBill](v.ReservationID))fn
	WHERE v.ReservationID = @ReservationID
END

