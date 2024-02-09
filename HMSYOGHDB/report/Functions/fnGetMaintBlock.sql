
CREATE FUNCTION [report].[fnGetMaintBlock] 
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strMaintBlockCount varchar(255);

	--set @strMaintBlockCount = (SELECT COUNT(ROOMID) FROM [Products].[BlockedRoom] WHERE blockTypeId = 11 AND FORMAT(@FromDate,'dd/MM/yyyy') >= FORMAT(Fromdate,'dd/MM/yyyy') and  FORMAT(@FromDate,'dd/MM/yyyy') <= FORMAT(Todate,'dd/MM/yyyy'))

	set @strMaintBlockCount = (SELECT COUNT(BR.RoomID) FROM [Products].[BlockedRoom] BR INNER JOIN [Products].[Room] Pr ON BR.RoomID = Pr.RoomID INNER JOIN Products.SubCategory rt ON PR.SubCategoryID = rt.SubCategoryID 
									Where Pr.RoomStatusID =10 and @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103))

			RETURN @strMaintBlockCount
END

 -- 11  Maintenance

-- SELECT *
--FROM [Products].[BlockedRoom] BR
--INNER JOIN [Products].[Room] Pr ON BR.RoomID = Pr.RoomID
--INNER JOIN Products.SubCategory rt ON PR.SubCategoryID = rt.SubCategoryID 
--Where Pr.RoomStatusID =10 and @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103)))
