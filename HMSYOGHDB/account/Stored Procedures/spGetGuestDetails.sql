
CREATE PROCEDURE [account].[spGetGuestDetails]
(
	@FolioNumber varchar(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT vwr.GuestID
	,vwr.ReservationID
	,(Title + ' ' + FirstName + CASE WHEN LEN(LastName) > 1 THEN ' ' + LastName ELSE '' END) as [Name]
	FROM [reservation].[vwReservationDetails] vwr	
	Where vwr.FolioNumber = @FolioNumber AND ReservationStatusID IN (3,4)	
END
