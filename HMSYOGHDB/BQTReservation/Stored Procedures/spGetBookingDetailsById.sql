CREATE PROCEDURE [BQTReservation].[spGetBookingDetailsById] 
   @BookingId int
  -- @UserId int=null
   --@Location int=null
AS
BEGIN
    SELECT DISTINCT B.BookingID, 
	TL.[Title] + ' ' + CD.FirstName +' '+ CD.LastName AS [Name]
		,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	    + (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address],
		CA.Email,CA.PhoneNumber,GC.CountryName,
	EM.EventTypeName,ES.EventName,RR.ReservationMode,
	RS.ReservationStatus,B.EventStartDate, B.EventStartTime,
        B.EventEndDate, B.EventEndTime, B.BQTRooms, B.MenuPlan, B.Setup,
        B.Notes,B.RoomRequired,       
        B.TotalAmountAfterTax,
        B.TotalPayable, B.AdvancePaid
        --B.RequiredAMTtoConfirm,
		
    FROM [BQTReservation].[BQTBooking] B
    INNER JOIN contact.Details CD ON  B.ContactID=CD.ContactID
	INNER JOIN person.Title TL ON CD.TitleID=TL.TitleID
	INNER JOIN contact.Address CA ON CD.ContactID=CA.ContactID
	INNER JOIN [general].[Country] GC ON CA.CountryID=GC.CountryID
	INNER JOIN BQTReservation.EventTypeMaster EM ON  B.EventTypeId=EM.EventTypeId
	INNER JOIN [BQTReservation].[Events] ES ON B.EventNameId=ES.EventId
	INNER JOIN reservation.ReservationMode RR ON B.BookingModeID=RR.ReservationModeID
	INNER JOIN reservation.ReservationStatus RS ON B.BookingStatusId=RS.ReservationStatusID 
	INNER JOIN contact.AddressType CT ON CA.AddressTypeID=CT.AddressTypeID
	Where B.BookingID=@BookingId
END


