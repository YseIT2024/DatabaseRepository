CREATE Proc [reservation].[GetreservationChart]   --2024,1,0,39
@YearId int,
@MonthId int,
@RoomNo int=0,
@SubCategoryId int=0
as
Begin
select  isnull(z.Code,'') as Code ,isnull(y.RoomNo,'') as RoomNo ,y.RoomNo as RoomOccupied, isnull([1],'') as [1], isnull([2],'') as [2],isnull( [3],'') as [3], isnull([4],'') as [4],
isnull([5],'') as [5],isnull([6],'') as  [6],isnull([7],'')as [7],isnull([8],'')as [8],isnull([9],'') as[9],isnull([10],'') as [10]
,isnull([11],'') as [11],isnull([12],'')as [12],isnull([13],'') as [13],isnull([14],'') as [14],isnull([15],'') as [15],
isnull([16],'') as [16],isnull([17],'')as [17],isnull([18],'') as [18],isnull([19],'') as [19],isnull([20],'') as [20]
,isnull([21],'') as[21],isnull([22],'') as [22],isnull([23],'') as [23],isnull([24],'') as [24],isnull([25],'') as [25],
isnull([26],'') as [26],isnull([27],'') as [27],isnull([28],'') as [28],isnull([29],'') as [29],isnull([30],'') as [30],isnull([31],'') as [31] from(
select * from (
select DATEPART(d,a.date_id) as DayOfthemonth, d.FullName+' ('+convert(varchar(20),d.ReservationID)+')'+' ['+convert(varchar(20),d.ReservationStatusID)+']' as  FullName,e.RoomNo as RoomOccupied
from general.Calendar a 
left join  [room].[vwOccupiedRoomsWithActualDates] b on a.date_id=b.date_id
left join reservation.vwReservationDetails d on d.ReservationID=b.reservationid
left join Products.Room e on e.RoomID=b.RoomId
--outer apply Products.Room c
where year(a.date_id)=@YearId and MONTH(a.date_id)=@MonthId)  as c 
PIVOT  
(max (FullName)  
FOR DayOfthemonth IN  
( [1], [2], [3], [4], [5],[6],[7],[8],[9],[10]
,[11],[12],[13],[14],[15],[16],[17],[18],[19],[20]
,[21],[22],[23],[24],[25],[26],[27],[28],[29],[30],[31])  
) AS pvt  
) as x right join Products.Room y on x.RoomOccupied=y.RoomNo --and (y.RoomNo=@RoomNo or @RoomNo=0)
left  join Products.SubCategory z on z.SubCategoryID=y.SubCategoryID --and (y.SubCategoryID=@SubCategoryID or @SubCategoryID=0)
where  (y.RoomNo=@RoomNo or @RoomNo=0) and (y.SubCategoryID=@SubCategoryID or @SubCategoryID=0)
End