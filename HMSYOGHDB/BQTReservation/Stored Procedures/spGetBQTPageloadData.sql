-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [BQTReservation].[spGetBQTPageloadData]
	
AS
BEGIN
	SELECT TitleID, Title
	FROM  person.Title
	SELECT AddressTypeID, AddressType
	FROM  contact.AddressType
	SELECT CountryID, CountryName  
	FROM  general.Country
	WHERE IsActive = 1
	select EventTypeId,EventTypeName from 
	BQTReservation.EventTypeMaster
	select ReservationModeID,ReservationMode 
	from reservation.ReservationMode
	select ReservationStatusID,ReservationStatus 
	from reservation.ReservationStatus

END
