 
CREATE Proc [Products].[GetAvailableRooms]  --'42','2023-12-23','2023-12-28',1004
@SubCatgegoryID int,
@ExpectedCheckInDate date,
@ExpectedCheckoutDate date,
@ReservationId int=0
as
Begin

 select distinct SC.Name,RM.RoomID,RM.RoomNo  from  [Products].[Item] IT  
				inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1  
				inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
				INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID  
		where  SC.SubCategoryID =@SubCatgegoryID AND RM.RoomID not in  
				(SELECT a.RoomId from Room.vwOccupiedRooms a where date_id between dateadd(dd,1,(convert(date,@ExpectedCheckInDate)))
				and dateadd(dd,-1,convert(date,@ExpectedCheckoutDate)) and (a.reservationid<>@ReservationId or @ReservationId=0))
		 order by RoomNo

end