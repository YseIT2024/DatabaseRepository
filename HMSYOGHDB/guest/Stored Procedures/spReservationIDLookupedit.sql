
CREATE proc [guest].[spReservationIDLookupedit] 
  as
  begin
 select 0 as ReservationID,0 as FolioNumber 
 union
  select distinct r.ReservationID,r.FolioNumber 
  from reservation.Reservation r
  inner join account.GuestLedgerDetails ag
  on ag.FolioNo=r.FolioNumber 
  order by FolioNumber asc

  end