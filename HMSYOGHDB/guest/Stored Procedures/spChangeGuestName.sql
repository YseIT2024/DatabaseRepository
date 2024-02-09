
CREATE PROCEDURE [guest].[spChangeGuestName]
(
	@ReservationID int,
    @Name varchar(100)
)
AS
BEGIN
	SET NOCOUNT ON;
	
	Update cd
	SET cd.FirstName = @Name
	,cd.LastName = ''
	FROM contact.Details cd
	INNER JOIN guest.Guest g ON cd.ContactID = g.ContactID
	INNER JOIN reservation.Reservation r ON g.GuestID = r.GuestID
	WHERE r.ReservationID = @ReservationID

	SELECT 1 'IsSuccess'
END

