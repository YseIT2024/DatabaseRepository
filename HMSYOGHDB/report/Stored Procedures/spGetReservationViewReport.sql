CREATE PROCEDURE [report].[spGetReservationViewReport] --550,1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int 
)
AS
BEGIN
	SET NOCOUNT ON;	

    SELECT r.RoomNo
	,rt.RoomType
	,1 [Nights]
	,CAST(rat.[Rate] as decimal(18,2)) [Rate]	
	,CAST(rat.[Rate] as decimal(18,2)) [Amount]
	,FORMAT(d.[Date],'dd-MMM-yyyy') [Date]
	FROM reservation.ReservedRoom rr
	INNER JOIN [reservation].[RoomRate] rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rr.IsActive = 1
	INNER JOIN general.[Date] d ON rat.DateID = d.DateID 
	INNER JOIN room.Room r ON rr.RoomID = r.RoomID
	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID		
	WHERE rr.ReservationID = @ReservationID AND rat.IsActive = 1 AND rat.IsVoid = 0

    DECLARE @RoomNo int = 
	(
		SELECT r.RoomNo 
		FROM reservation.ReservedRoom rr
		INNER JOIN room.Room r ON rr.RoomID = r.RoomID 		
		WHERE rr.ReservationID = @ReservationID AND rr.IsActive = 1
	);

	
	SELECT AccountTypeID [AccountTypeID]
	,@RoomNo [RoomNo] 
	,[AccountType] 
	,[AccountingDate]
	,CAST([Debit] as decimal(18,2)) [Debit]
	,CAST([Credit] as decimal(18,2)) [Credit]
	,[Remarks]
	FROM [guest].[vwGuestFolio] 
	WHERE ReservationID = @ReservationID AND AccountTypeID != 82
END
