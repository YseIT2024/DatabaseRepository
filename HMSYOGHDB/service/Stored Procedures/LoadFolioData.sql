CREATE PROCEDURE [service].[LoadFolioData] 
(
   @UserID INT,
   @ReservationStatusID int=0

)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	if @ReservationStatusID >0 
		begin
		
			SELECT RR.ReservationID, RR.FolioNumber, FORMAT(RR.ActualCheckIn, 'dd-MMM-yyyy hh:mm tt') AS ActualCheckIn, FORMAT(RR.ExpectedCheckOut, 'dd-MMM-yyyy hh:mm tt') As ExpectedCheckOut,TL.[Title] + ' ' + CD.FirstName +' ' + CD.LastName as GuestName, (RR.Adults + RR.Children) PaxCount,RR.GuestID,
			(select top (1) pi.ItemName from reservation.ReservationDetails rd 
			inner join  products.Item pi on rd.ItemID=pi.ItemID where rd.ReservationID=rr.ReservationID) itemname,	
			(select top (1) pr.RoomNo from [reservation].[ReservedRoom] rrr 
			inner join [Products].[Room] pr on rrr.RoomID=pr.RoomID where rrr.reservationid=rr.ReservationID and rrr.IsActive=1) roomno,
			(select [reservation].[fnGetReserveredRoom](RR.ReservationID)) as RoomNos
			
			--(SELECT STRING_AGG(PR.RoomNo, ',')  FROM [reservation].[ReservedRoom] RRR
			--inner join [Products].[Room] PR On RRR.RoomID = PR.RoomID
			--where RRR.reservationid=RR.ReservationID) as roomno

			From [reservation].[Reservation] RR
			Inner join [guest].[Guest] GT on RR.GuestID = GT.GuestID
			Inner join [contact].[Details] CD on GT.ContactID = CD.ContactID
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			Where RR.ReservationStatusID = @ReservationStatusID 
			ORDER BY FolioNumber
		end
	else
		begin
		SELECT RR.ReservationID, RR.FolioNumber, FORMAT(RR.ActualCheckIn, 'dd-MMM-yyyy hh:mm tt') AS ActualCheckIn, FORMAT(RR.ExpectedCheckOut, 'dd-MMM-yyyy hh:mm tt') As ExpectedCheckOut, TL.[Title] + ' ' + CD.FirstName + ' '+ CD.LastName as GuestName, (RR.Adults + RR.Children) PaxCount,RR.GuestID,
			(select top (1) pi.ItemName from reservation.ReservationDetails rd inner join  products.Item pi on rd.ItemID=pi.ItemID where rd.ReservationID=rr.ReservationID) itemname,	
			(select top (1) pr.RoomNo from [reservation].[ReservedRoom] rrr inner join [Products].[Room] pr on rrr.RoomID=pr.RoomID where rrr.reservationid=rr.ReservationID and rrr.IsActive=1) roomno,
			(select [reservation].[fnGetReserveredRoom](RR.ReservationID)) as RoomNos
			--(SELECT STRING_AGG(PR.RoomNo, ',')  FROM [reservation].[ReservedRoom] RRR
			--inner join [Products].[Room] PR On RRR.RoomID = PR.RoomID
			--where RRR.reservationid=RR.ReservationID) as roomno

			From [reservation].[Reservation] RR
			Inner join [guest].[Guest] GT on RR.GuestID = GT.GuestID
			Inner join [contact].[Details] CD on GT.ContactID = CD.ContactID	
			inner join [person].[Title] TL on CD.TitleID = TL.TitleID
			Where RR.ReservationStatusID = 3 AND RR.ExpectedCheckOut >= GETDATE()
			ORDER BY FolioNumber
		end
END
