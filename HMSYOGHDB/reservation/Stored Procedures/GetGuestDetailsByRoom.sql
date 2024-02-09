CREATE Proc [reservation].[GetGuestDetailsByRoom] --201
@RoomNo int
as
Begin
Declare @CustomerName varchar(50)=''
Declare @MobileNumber varchar(50)=''
Declare @EmailId varchar(50)=''
Declare @ReservationId int=0
Declare @FolioNumber int=0
if exists(select a.ReservationID from reservation.ReservedRoom a inner join Products.Room b on a.RoomID=b.RoomID
inner join Reservation.Reservation c on c.ReservationID=a.ReservationID and a.IsActive=1 and c.ReservationStatusID=3)
Begin
select @CustomerName=d.FullName,@MobileNumber=PhoneNumber,@EmailId=Email,@ReservationId=a.ReservationID,@FolioNumber=FolioNumber
from reservation.ReservedRoom a inner join Products.Room b on a.RoomID=b.RoomID
inner join Reservation.Reservation c on c.ReservationID=a.ReservationID and a.IsActive=1 and c.ReservationStatusID=3
inner join guest.vwGuestDetails d on d.GuestID=c.GuestID where RoomNo=@RoomNo

select 1 as Result,'Please Find the customer Details'as Message,@CustomerName as CustomerName,
@MobileNumber as MobileNumber,@EmailId as EmailId,@ReservationId as ReservationId, @FolioNumber as FolioNumber
	
End
else
Begin
select 0 as Result,'There is no active reservation!' as Message,@CustomerName as CustomerName,
@MobileNumber as MobileNumber,@EmailId as EmailId,@ReservationId as ReservationId, @FolioNumber as FolioNumber
ENd
End