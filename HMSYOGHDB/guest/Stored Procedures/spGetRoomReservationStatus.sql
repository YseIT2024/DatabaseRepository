create proc guest.spGetRoomReservationStatus
@YearId int,
@MonthId int,
@RoomNo int=0,
@SubCategoryId int=0
as
Begin

SELECT 
        A.Name AS RoomType,
      IT.ItemName AS MealPlan,
	   GC.date_id AS Date
	   

        FROM [Products].[SubCategory] A
        INNER JOIN [Products].[Item] IT ON A.SubCategoryID = IT.SubCategoryID
		inner join general.Calendar GC on a.CreateDate=gc.date_id
		where year(GC.date_id)=@YearId and MONTH(GC.date_id)=@MonthId
		

end