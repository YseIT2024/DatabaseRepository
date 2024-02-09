CREATE PROC [reservation].[usp_ReservationServices_Delete]
@TransId int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   reservation.ReservationServices
    WHERE  TransId = @TransId

    COMMIT
