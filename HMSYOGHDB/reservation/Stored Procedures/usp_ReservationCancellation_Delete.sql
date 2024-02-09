CREATE PROC [reservation].[usp_ReservationCancellation_Delete]
@ReservationID int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   reservation.ReservationCancellation
    WHERE  ReservationID = @ReservationID

    COMMIT
