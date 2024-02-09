CREATE Proc [room].[GetOccupancyDetailsByRoom] --219,'01-Dec-2023','31-Dec-2023'
@RoomNo int,
@FromDate date,
@Todate date
as
Begin

declare @OccupancyTable table(date_id date,RoomDetails varchar(500),RoomStatus varchar(50),ReservationId int,GuestDetails varchar(50), LastUpdatedDate datetime)
declare @RoomsBlocked Table (date_id date,RoomStatus varchar(50),ReservationId int,GuestDetails varchar(50), LastUpdatedDate datetime)

Declare @RoomDetails varchar(500) =(select Convert(varchar(10),RoomNo)+' - '+b.Name+' ('+b.Code +')'
from Products.Room a 
inner join Products.SubCategory b on a.SubCategoryID=b.SubCategoryID
inner join Products.Category c on b.CategoryID=c.CategoryID where RoomNo=@RoomNo)

insert into @OccupancyTable select date_id,@RoomDetails,case when date_id<convert(date,getdate()) then 'Expired' else 'Available' end,Null,'',NULL from general.calendar a where a.date_id between @fromdate and @Todate

--select * from @OccupancyTable

insert into @RoomsBlocked
select a.date_id,min(b.Roomstatus) as status,ISNULL(b.ReservationId,0) AS ReservationId,e.FullName,max(Convert(date,b.CreateDate)) as modifiedDate
from general.calendar a 
inner join Room.vwOccupiedRooms b on a.date_id=b.date_id 
inner join Products.Room c on c.RoomID=b.roomid
inner join reservation.Reservation d on d.ReservationID=b.reservationId
left join guest.vwGuestDetails e on e.GuestID=d.GuestID
where (Roomno=@RoomNo or a.date_id is null) and a.date_id between @fromdate and @Todate 
group by a.date_id,b.ReservationId,e.FullName 

update t1 set t1.RoomStatus=t2.RoomStatus,t1.ReservationId=t2.ReservationId,t1.GuestDetails=t2.GuestDetails,t1.LastUpdatedDate=t2.LastUpdatedDate
from @OccupancyTable t1 inner join @RoomsBlocked t2 on t1.date_id=t2.date_id and t1.date_id>=convert(date,getdate())

select * from @OccupancyTable

End
