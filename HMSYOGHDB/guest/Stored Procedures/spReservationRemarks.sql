
CREATE proc [guest].[spReservationRemarks] --0 --10129 
@FolioNo int
  as
  begin

  select 
  AG.FolioNo,R.ReservationID,
  AG.Remarks,
  AG.CreatedOn,
  AG.AmtAfterTax
  from account.GuestLedgerDetails AG
  inner join reservation.Reservation R 
  on R.FolioNumber=AG.FolioNo
  where  @FolioNo=0 or AG.FolioNo=@FolioNo

  end