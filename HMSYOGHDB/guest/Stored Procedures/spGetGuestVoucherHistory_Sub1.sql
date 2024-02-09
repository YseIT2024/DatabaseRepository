
CREATE PROCEDURE [guest].[spGetGuestVoucherHistory_Sub1]
(	
	@ActualStay int,
	@ReservationID int,
	@GuestID int
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT DISTINCT rw.FolioNumber
	,rw.FullName as [GuestName]
	,rw.CountryName	
	,rw.Nights
	,CASE WHEN @ActualStay <= 0 THEN 1 ELSE @ActualStay END [ActualStay]
	,FORMAT([ExpectedCheckIn],'dd-MMM-yyyy') [ExpectedCheckIn]
	,FORMAT([ExpectedCheckOut],'dd-MMM-yyyy') [ExpectedCheckOut]
	,FORMAT([ActualCheckIn],'dd-MMM-yyyy HH:mm') [ActualCheckIn]
	,FORMAT(ActualCheckOut,'dd-MMM-yyyy HH:mm') ActualCheckOut
	,FORMAT([DateTime],'dd-MMM-yyyy') [ReservationDate]
	,FORMAT(GETDATE(),'dd-MMM-yyyy') [Date]	
	,r.RoomNo
	,CAST(bill.[AvgRate] as decimal(18,2)) [AvgRate]
	,CAST(bill.TotalAmount as decimal(18,2)) [TotalAmount]
	,CAST(vdcomp.VoidAmount as decimal(18,2)) [VoidAmount]
	,CAST(vdcomp.ComplimentaryAmount as decimal(18,2)) [ComplimentaryAmount]
	,CAST((SELECT [reservation].[fnGetReservationDiscountAmount](@ReservationID,@GuestID)) as decimal(18,2)) [Discount]
	,CAST((SELECT [account].[fnGetReservationPayment](@ReservationID)) as decimal(18,2)) [OtherPayment]
	,rr.RateCurrencyID
	FROM [reservation].[vwReservationDetails] rw 
	INNER JOIN reservation.ReservedRoom rr ON rw.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	
	CROSS APPLY (SELECT * FROM [reservation].[fnGetReservationRoomBill](rw.ReservationID)) bill 
	CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](rw.ReservationID)) vdcomp
	WHERE rw.ReservationID = @ReservationID AND rw.ReservationStatusID = 4  
END

