CREATE PROCEDURE [reservation].[MoveInHOuseGetProductDetail_New] --45,'12/18/2023','12/21/2023',0,0,0,0
(	
	@SubCategoryID int,
	@ExpectedCheckInDate datetime,
	@ExpectedCheckOutDate datetime,
	@NoOfAdults int,
	@NoOfChild int,
	@NoOfRooms int,
	@CompanyID int

)
AS
BEGIN

 

		Declare @TotalRoomCount int,@reservedRooms int,@AvailableRooms int, @DateDifference int

		set @DateDifference=DATEDIFF(DAY,GETDATE(),@ExpectedCheckInDate)

		if(@CompanyID < 1)
		BEGIN
			
			select @TotalRoomCount=ps.TotalInventory From Products.subcategory ps where SubCategoryID=@SubCategoryID
			
			

			SELECT @reservedRooms = COUNT(*)
				FROM (
					SELECT RD.ItemID, RR.ReservationID
					FROM reservation.Reservation RR
					INNER JOIN reservation.ReservationDetails RD ON RD.ReservationID = RR.ReservationID
					INNER JOIN Products.Item IT ON IT.ItemID = RD.ItemID
					WHERE IT.SubCategoryID = @SubCategoryID AND RR.ReservationStatusID IN (1, 3, 12, 15)--Reserved, IN-House,Requested,No Show
					 AND (@ExpectedCheckInDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut) OR 
					 @ExpectedCheckOutDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut))
					GROUP BY RD.ItemID, RR.ReservationID
				) T;
		
			

			SET @AvailableRooms = ISNULL(@TotalRoomCount, 0) - ISNULL(@reservedRooms, 0);
            SELECT ISNULL(@TotalRoomCount, 0) AS TotalRoomCount, ISNULL(@AvailableRooms, 0) AS AvailableRooms;

			
			SELECT  
			PIT.ItemID,ItemCode,ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult  --,SubCategoryID,PRP.SalePrice
			, MAX(PRP.SalePrice) SalePrice , 
			MAX(PRP.BasePrice) BasePrice      -- Added BY Somnath
			FROM Products.Item PIT
			inner join Products.RoomPriceNew PRP on PIT.ItemID=PRP.ItemID AND FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate  -- Added BY Somnath
			WHERE SubCategoryID= @SubCategoryID 
			and PIT.IsActive=1
			Group By PIT.ItemID,ItemCode,ItemName
			Order By PIT.ItemID
			
		END
		ELSE
		BEGIN
		

			select @TotalRoomCount=ps.TotalInventory From Products.subcategory ps where SubCategoryID=@SubCategoryID

			SELECT @reservedRooms = COUNT(*)
				FROM (
					SELECT RD.ItemID, RR.ReservationID
					FROM reservation.Reservation RR
					INNER JOIN reservation.ReservationDetails RD ON RD.ReservationID = RR.ReservationID
					INNER JOIN Products.Item IT ON IT.ItemID = RD.ItemID
					WHERE IT.SubCategoryID = @SubCategoryID  AND RR.ReservationStatusID IN (1, 3, 12, 15)--Reserved, IN-House,Requested,No Show
					 AND (@ExpectedCheckInDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut) OR 
					 @ExpectedCheckOutDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut))
					GROUP BY RD.ItemID, RR.ReservationID
				) T;

		
			set  @AvailableRooms=@TotalRoomCount-@reservedRooms 
			select @TotalRoomCount TotalRoomCount ,@AvailableRooms AvailableRooms


			SELECT distinct IT.ItemID,IT.ItemCode,IT.ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult
			, MAX(PRP.SalePrice) SalePrice, MAX(PRP.BasePrice) BasePrice    -- Added BY Somnath
			FROM Products.Item IT
			Inner join company.RateContracts GC on IT.ItemID = GC.ItemID
			inner join company.RoomPriceNew PRP on IT.ItemID=PRP.ItemID  AND FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate  
			-- Added BY Somnath
			WHERE SubCategoryID=@SubCategoryID and GC.CompanyID = @CompanyID	
			and it.IsActive=1 and GC.IsActive=1
			Group BY IT.ItemID,IT.ItemCode,IT.ItemName
		END

		SELECT min(StandardReservationDepositPercent) as RequiredReservationDeposit FROM  [reservation].[StandardReservationDeposit] 
			where  @DateDifference >=ReservationDayFrom and @DateDifference <=ReservationDayTo
			
END