
CREATE FUNCTION [report].[fnRoomTypePosition] 
(	
	@FromDate datetime,
	@SubCategoryID int

)
RETURNS varchar(255)
AS	
BEGIN

DECLARE @Total INT;
DECLARE @strAvailableRoomCount INT;
DECLARE @strExpertCheckInCount INT;
DECLARE @strStayOnInHouseCount INT;
DECLARE @strMaintBlockCount INT;


DECLARE @strRoomTypeCount varchar(255);

	--set @strRoomTypeCount = (select * from [Report].[RandomNumberGenerate])


	-- TOTAL INVENTORY
		set @strAvailableRoomCount =(select sum([TotalInventory]) from [Products].[SubCategory] where categoryid=1 and isactive=1 and SubCategoryID=@SubCategoryID)
		--set @strAvailableRoomCount=(@strAvailableRoomCount-(SELECT COUNT(ROOMID) FROM [Products].[BlockedRoom] WHERE STATUS = 'B' AND @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103)))
		set @strAvailableRoomCount=(@strAvailableRoomCount-(SELECT COUNT(BR.RoomID) FROM [Products].[BlockedRoom] BR
																	INNER JOIN [Products].[Room] Pr ON BR.RoomID = Pr.RoomID INNER JOIN Products.SubCategory rt ON PR.SubCategoryID = rt.SubCategoryID 
																	WHERE STATUS = 'B' AND @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103) and rt.SubCategoryID=@SubCategoryID))
		-- EXP CHECK IN
		set @strExpertCheckInCount =ISNULL((select COUNT(R.Rooms) from reservation.Reservation R
												INNER JOIN reservation.ReservationDetails RD ON R.ReservationID= RD.ReservationID
												INNER JOIN Products.Item ON RD.ItemID = Item.ItemID
												INNER JOIN Products.SubCategory SC ON SC.SubCategoryID = Item.SubCategoryID
												where format(ExpectedCheckIn, 'dd/MM/yyyy')=format(@FromDate, 'dd/MM/yyyy') and ReservationStatusID in (1,12,16) and SC.SubCategoryID=@SubCategoryID),0)
		--IN HOUSE
		set @strStayOnInHouseCount = ISNULL((select COUNT(R.Rooms) from reservation.Reservation R
												INNER JOIN reservation.ReservationDetails RD ON R.ReservationID= RD.ReservationID
												INNER JOIN Products.Item ON RD.ItemID = Item.ItemID
												INNER JOIN Products.SubCategory SC ON SC.SubCategoryID = Item.SubCategoryID
												where format(ExpectedCheckIn, 'dd/MM/yyyy')=format(@FromDate, 'dd/MM/yyyy') and ReservationStatusID in (3) and SC.SubCategoryID=@SubCategoryID),0)

		--BLOCKED ROOM
		set @strMaintBlockCount = ISNULL((SELECT COUNT(BR.RoomID) FROM [Products].[BlockedRoom] BR INNER JOIN [Products].[Room] Pr ON BR.RoomID = Pr.RoomID INNER JOIN Products.SubCategory rt ON PR.SubCategoryID = rt.SubCategoryID 
									Where Pr.RoomStatusID =10 and @FromDate >=CONVERT(date, Fromdate, 103) and @FromDate <=CONVERT(date, Todate, 103) and  rt.SubCategoryID =@SubCategoryID),0)

		set @Total = (@strAvailableRoomCount - (@strExpertCheckInCount + @strStayOnInHouseCount + @strMaintBlockCount))

		set @strRoomTypeCount = @Total



	RETURN @strRoomTypeCount
END

 
