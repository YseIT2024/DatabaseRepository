
CREATE view [room].[vwOccupiedRoomsWithActualDates]
as
select RoomId,RoomStatus,reservationid, convert(date,fromdate) as Fromdate , CONVERT(date,Todate) as Todate,date_id,a.CreateDate
from Products.RoomLogs  a cross apply general.Calendar b   
inner join Products.RoomStatus c on a.RoomStatusID=c.RoomStatusID
where b.date_id between CONVERT (date,convert(char(8),fromdateid)) and dateadd(D,-1, CONVERT (date,convert(char(8),ToDateID)))
and date_id>dateadd(DD,-7,getdate()) and a.RoomStatusID 
not in (1,8)
