
CREATE Proc [report].[spGetCheckOutReceipt] --80,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int,
	@UserID int = null
)
AS
BEGIN
	SET NOCOUNT ON;	

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 4)
	BEGIN
		EXEC [report].[spGetCheckOutReceipt_sub1_Details] @ReservationID,@LocationID,@DrawerID;
		EXEC [report].[spGetCheckOutReceipt_sub2_Room] @ReservationID,@LocationID;
		SELECT VoidAmount,ComplimentaryAmount  FROM [reservation].[fnGetVoidAndComplimentaryAmount](@ReservationID)

		-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Check Out Receipt', @UserID
	END
END










