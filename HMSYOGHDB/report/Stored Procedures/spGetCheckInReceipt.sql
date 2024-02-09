
CREATE Proc [report].[spGetCheckInReceipt] --1114, 1,1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int,
	@UserID int = null
)
AS
BEGIN
	SET NOCOUNT ON;	

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID AND ReservationStatusID = 3)
	BEGIN
		EXEC [report].[spGetCheckInReceipt_sub2_Details] @ReservationID, @LocationID,@DrawerID;
		EXEC [report].[spGetCheckInReceipt_sub1_Room] @ReservationID, @LocationID;		

		-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Check In Receipt', @UserID	
	END
END






