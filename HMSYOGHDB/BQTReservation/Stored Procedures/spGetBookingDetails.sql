CREATE PROCEDURE [BQTReservation].[spGetBookingDetails]
   @UserId int=null
   --@Location int=null
AS
BEGIN
    SELECT DISTINCT B.BookingID,B.ContactID, 
	TL.[Title] + ' ' + CD.FirstName +' '+ CD.LastName AS [Name]
		,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	    + (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address],CA.AddressID,
		CA.Email,CA.PhoneNumber,CA.ContactID,CA.ZipCode,CA.State,CA.City,CA.Street,CA.AddressTypeID,CD.DOB,CD.FirstName,CD.LastName,TL.TitleID,CA.CountryID,GC.CountryName,
	EM.EventTypeName,ES.EventName,RR.ReservationMode,
	RS.ReservationStatus,B.EventStartDate, B.EventStartTime,
        B.EventEndDate, B.EventEndTime, B.BQTRooms, B.MenuPlan, B.Setup,
        B.Notes, B.EventTypeId, B.EventNameId, B.RoomRequired, B.MediaRequired, 
        B.TotalPax, B.BookingStatusId, B.TotalAmountBeforeTax, 
        B.TotalTaxAmount, B.TotalAmountAfterTax,
        B.AdditionalDiscountAmount, B.TotalPayable, B.AdvancePaid
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
	INNER JOIN contact.AddressType CT ON CA.AddressTypeID=CT.AddressTypeID Order by B.BookingID desc
END


