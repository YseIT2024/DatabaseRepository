CREATE PROC [reservation].[spGetReservationDeails]  --6767-- null,null
@ReservationID varchar(20)   
AS 
BEGIN
 SET NOCOUNT ON
    SET XACT_ABORT ON

	
    SELECT
        CASE WHEN RR.FolioNumber > 0 THEN  LTRIM(STR(RR.FolioNumber)) ELSE 'N/A' END AS [FolioNumber],CA.Email,CA.PhoneNumber,
        CASE WHEN ActualCheckIn IS NULL THEN '' ELSE FORMAT([ActualCheckIn],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckIn],
        CASE WHEN ActualCheckOut IS NULL THEN '' ELSE FORMAT([ActualCheckOut],'dd-MMM-yyyy hh:mm tt') END AS [ActualCheckOut],
        FORMAT([ExpectedCheckIn],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckIn],
        FORMAT([ExpectedCheckOut],'dd-MMM-yyyy hh:mm tt') AS [ExpectedCheckOut],
        FORMAT(RR.[DateTime],'dd-MMM-yyyy hh:mm tt') AS [DateTime],
        TL.[Title] + ' ' + CD.FirstName +' '+ CD.LastName AS [Name]
		,(CASE When LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
	    + (CASE When LEN([State]) > 0 THEN [State] +', ' ELSE '' END) + [CountryName] + (CASE When LEN([ZipCode]) > 0 THEN ', '+ [ZipCode]  ELSE '' END) as [Address]
	
    FROM reservation.Reservation RR
    INNER JOIN reservation.ReservationStatus RS ON RS.ReservationStatusID=RR.ReservationStatusID
    INNER JOIN reservation.ReservationMode RM ON RM.ReservationModeID=RR.ReservationModeID
    INNER JOIN guest.Guest GG ON GG.GuestID=RR.GuestID
    INNER JOIN contact.Details CD ON CD.ContactID=GG.ContactID
    INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
    INNER JOIN reservation.ReservationType RT ON RT.ReservationTypeID=RR.ReservationTypeID
    INNER JOIN contact.Address CA ON CA.ContactID=CD.ContactID
    INNER JOIN general.Country GC ON GC.CountryID=CA.CountryID	
    WHERE RR.ReservationID = @ReservationID
END