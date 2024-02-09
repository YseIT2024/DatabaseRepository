
CREATE PROCEDURE [account].[spGetCustomerByReservationID]
(
	@ReservationID INT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT vwr.GuestID 
	,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) as [Name]
	FROM [reservation].[vwReservationDetails] vwr	
	Where vwr.ReservationID = @ReservationID	
END









