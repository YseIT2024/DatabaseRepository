CREATE FUNCTION [report].[fnGetAvailableRoom] 
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strAvailableRoomCount varchar(255);
	 
	--set @strAvailableRoomCount = (select * from [Report].[RandomNumberGenerate])
	---Total Inventory - Blocked / out of order
	--SELECT COUNT(ROOMID) FROM [Products].[BlockedRoom] WHERE STATUS = 'B' AND @FromDate >=Fromdate and @FromDate <=Todate

	set @strAvailableRoomCount =(select sum([TotalInventory]) from [Products].[SubCategory] where categoryid=1 and isactive=1)
	set @strAvailableRoomCount=(@strAvailableRoomCount-(SELECT COUNT(ROOMID) FROM [Products].[BlockedRoom] WHERE STATUS = 'B' AND @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103)))

	RETURN @strAvailableRoomCount
END




--(SELECT   STRING_AGG(Remarks, ',')  FROM Products.Room PR  where PR.RoomID in (SELECT distinct RoomID  FROM [reservation].[ReservedRoom]   where ReservationID=@ReservationId))

