CREATE Proc Reservation.GetInhouseGuestRooms
as
Begin
select distinct c.RoomID,c.RoomNo  from reservation.Reservation a 
inner join Reservation.ReservedRoom b on a.ReservationID=b.ReservationID
inner join Products.Room c on c.RoomID=b.RoomID where a.ReservationStatusID=3 
and b.IsActive=1
End