
CREATE PROC [Accounts].[spGetRefundPendingList] -- null,null
	--@LocationID int =null,	
	--@UserId int	 null
   
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	
	SELECT RC.CancellationID,Rc.CancellationModeID,rc.ReservationID,RC.Reason,rc.Refund,rc.RequestedOn,
	RR.GuestID,CD.ContactID,
	CD.FirstName + ' ' + CD.LastName AS GuestName,
	RM.ReservationMode,
    CA.Street + ', ' + CA.City + ', ' + CA.State + ',' + CA.Email + ',' + CA.PhoneNumber AS Address,ISNull(RR.OnlineReservationID,0) As OnlineReservationID,
	RD.LineTotal,RC.CancellationCharge,TS.Amount
	,ISNULL(RR.BookedRefNo,0) As	BookedRefNo--RD.LineTotal  
	FROM [reservation].[CancellationDetail] RC
	LEFT JOIN reservation.Reservation RR On rc.ReservationID=RR.ReservationID
	INNER JOIn reservation.ReservationDetails RD On RR.ReservationID=RD.ReservationID
	INNER JOIN [guest].[Guest] GG on RR.GuestID=gg.GuestID
	LEFT JOIN account.[Transaction] TS ON RR.ReservationID=TS.ReservationID
	INNER JOIN [contact].[Details] CD ON GG.ContactID=CD.ContactID
	INNER JOIN [reservation].[ReservationMode] RM ON RC.CancellationModeID=RM.ReservationModeID 
	INNER JOIN [contact].[Address] CA ON GG.ContactID=CA.ContactID Where RC.Refund>0 And TS.TransactionTypeID=2
	AND RC.CancellationID NOT IN (SELECT [CancellationID] FROM [HMSYOGH].[reservation].[Refund])    --Added By Somnath
	Order By  RC.CancellationID DESC  --Added By Somnath
	
END	
