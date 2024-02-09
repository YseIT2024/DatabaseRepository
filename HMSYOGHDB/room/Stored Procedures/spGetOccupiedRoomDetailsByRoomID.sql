
CREATE PROCEDURE [room].[spGetOccupiedRoomDetailsByRoomID]
(
	@LocationID INT,
	@RoomID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT
	r.RoomID,
	r.RoomNo,
	(Title + ' ' + d.FirstName + CASE WHEN LEN(d.LastName) > 1 THEN ' ' + d.LastName ELSE '' END) as [Name]
	,'' [IDCardNumber]
	,ExpectedCheckIn
	,ExpectedCheckOut
	,PhoneNumber
	,Email
	FROM [reservation].[vwReservationDetails] vwr
	INNER JOIN [reservation].[ReservedRoom] rr ON vwr.ReservationID = rr.ReservationID
	INNER JOIN [contact].[Details] d ON vwr.ContactID = d.ContactID
	INNER JOIN [room].[Room] r ON rr.RoomID = r.RoomID AND r.RoomID = @RoomID AND r.IsActive = 1
	Where vwr.LocationID = @LocationID AND rr.IsActive = 1
END


