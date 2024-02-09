CREATE PROC [reservation].[usp_ReservationGuestMates_Select]
    @GuestMatesID int
AS
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    SELECT GuestMatesID, ReservationID, FirstName, MiddleName, LastName, Gender, DOB, GuestType, Nationality, PIDType, PIDNo, ActualCheckIn, ExpectedCheckOut, ActualCheckOut, UserID, CreatedDate, IsActive
    FROM   reservation.ReservationGuestMates
    WHERE  GuestMatesID = @GuestMatesID 

    COMMIT
