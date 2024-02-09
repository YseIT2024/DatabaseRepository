
CREATE Proc [guest].[spGetReservationGridIntervals] --2023,1,45
@YearId int,
@MonthId int,
@SubCategoryId int

as
Begin

-- Populate the table-valued parameter with data

    SELECT distinct
    IT.ItemName AS ItemName,
    A.Name AS RoomType,
    GC.date_id AS Date,
    ID.Price,
    ID.Booked,
    ID.TotalCount,
    ID.Available
   

FROM 
    [Products].[SubCategory] A
    CROSS APPLY general.Calendar GC
INNER JOIN [Products].[Item] IT ON A.SubCategoryID = IT.SubCategoryID and a.CategoryID=1

cross apply dbo.ItemData ID

WHERE 
    YEAR(GC.date_id) = @YearId 
    AND MONTH(GC.date_id) = @MonthId 
    AND A.CategoryID = 1 
    and (A.SubCategoryID = @SubCategoryID   or @SubCategoryID =0)

ORDER BY Date ASC;

end


--truncate table dbo.ItemData
--insert into dbo.ItemData(Price,Booked,TotalCount,Available) values(1800,5,25,20)

