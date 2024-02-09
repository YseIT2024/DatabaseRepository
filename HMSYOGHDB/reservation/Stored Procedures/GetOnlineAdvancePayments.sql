Create PROCEDURE [reservation].[GetOnlineAdvancePayments]--'26-Oct-2023','28-Oct-2023'
(
@FromDate date=null,
@ToDate date=null,
@LocationId int= null,
@UserId int= null

)
AS
     BEGIN

			SELECT ATA.Amount ,RR.OnlineReservationID,ATM.TransactionMode,RR.ReservationID,
			FORMAT(RR.DateTime, 'dd-MMM-yyyy HH:mm:ss') AS DateTime, ISNULL(cd.PhoneNumber,'')as PhoneNumber,ISNULL(cd.Email,'')as Email,
			--,CDS.FirstName,CDS.LastName
			COALESCE(CONCAT(CDS.FirstName, ' ', CDS.LastName), 'N/A') AS FullName
			FROM [account].[Transaction] ATA
			INNER JOIN reservation.Reservation RR ON ATA.ReservationID = RR.ReservationID
			INNER JOIN [account].[TransactionMode] ATM ON RR.Hold_TransactionModeID=ATM.TransactionModeID
			INNER JOIN guest.Guest gg On RR.GuestID=gg.GuestID
			INNER JOIN contact.Address cd ON gg.ContactID=cd.ContactID
			INNER JOIN contact.Details CDS ON cd.ContactID=CDS.ContactID

			where RR.OnlineReservationID >0	

			AND (RR.DateTime BETWEEN @FromDate AND @ToDate)
 
	END




