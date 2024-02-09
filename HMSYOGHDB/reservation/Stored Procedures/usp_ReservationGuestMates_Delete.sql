CREATE PROC [reservation].[usp_ReservationGuestMates_Delete]
@GuestMatesID int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   reservation.ReservationGuestMates
    WHERE  GuestMatesID = @GuestMatesID

    COMMIT
