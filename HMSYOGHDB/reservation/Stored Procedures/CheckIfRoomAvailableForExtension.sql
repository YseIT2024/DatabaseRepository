CREATE Proc Reservation.CheckIfRoomAvailableForExtension
@ReservationId int,
@ExpectedCheckIn date,
@ExpectedCheckOut date,
@RoomNumber varchar(50) output

as
Begin
Declare @RoomId int
Declare @RoomNo int
Declare @Incr int=1
Declare @RoomCount int=(select count(distinct RoomId) from Products.RoomLogs where reservationid=@ReservationId )

declare @RoomTable table(ID int identity(1,1), RoomId int, RoomNumber int)
insert into @RoomTable 
select distinct a.RoomId,b.RoomNo from Products.RoomLogs a inner join 
Products.Room b on a.RoomID=b.RoomID where reservationid=@ReservationId 

set @RoomNumber='available'

 while(@Incr<=@RoomCount)
 Begin
 select @RoomId=RoomId,@RoomNo=RoomNumber from @RoomTable where ID=@Incr

if exists(SELECT a.RoomId from Room.vwOccupiedRooms a where date_id between dateadd(dd,1,(convert(date,@ExpectedCheckIn)))
				and dateadd(dd,-1,convert(date,@ExpectedCheckOut)) and (a.reservationid<>@ReservationId) and roomid=@RoomId)
Begin
	if(@RoomNumber='available')
		 set @RoomNumber=convert(varchar(50),@RoomNo)+', '
	 else
		set  @RoomNumber +=convert(varchar(50),@RoomNo)+', '
End

 set @Incr +=1
 End


return
End