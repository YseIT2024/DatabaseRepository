

CREATE PROCEDURE [reservation].[GetProductDetails] --45,'12/18/2023','12/21/2023',0,0,0,0
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

		--Declare @SubCategoryID int=47, @ExpectedCheckInDate datetime='12/1/2022 3:02:44 PM',@ExpectedCheckOutDate datetime='12/2/2022 3:02:44 PM',
		--@NoOfAdults int=5,@NoOfChild int=2,@NoOfRooms int=2

		Declare @TotalRoomCount int,@reservedRooms int,@AvailableRooms int, @DateDifference int

		set @DateDifference=DATEDIFF(DAY,GETDATE(),@ExpectedCheckInDate)

		if(@CompanyID < 1)
		BEGIN
			--Begin Commented by Arabinda on 2023-09-27 to get the counts from subcategory tables------------------
			--select @TotalRoomCount=COUNT(RoomNo) 
			--from Products.Room where SubCategoryID=@SubCategoryID and MaxAdultCapacity>=@NoOfAdults/@NoOfRooms and MaxChildCapacity>=@NoOfChild/@NoOfRooms
			select @TotalRoomCount=ps.TotalInventory From Products.subcategory ps where SubCategoryID=@SubCategoryID
			
			---------------End------------------------

			--select @reservedRooms= count (RR.ReservationID)  
			--from reservation.Reservation RR
			--inner join reservation.ReservationDetails RD on RD.ReservationID=RR.ReservationID
			--inner join Products.Item IT on IT.ItemID=RD.ItemID
			--where IT.SubCategoryID=@SubCategoryID and RR.ReservationStatusID in(1,3) 
			--and (@ExpectedCheckInDate BETWEEN ExpectedCheckIn AND ExpectedCheckOut OR @ExpectedCheckOutDate BETWEEN ExpectedCheckIn AND ExpectedCheckOut)

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
		
			--set  @AvailableRooms=@TotalRoomCount-@reservedRooms 
			--select @TotalRoomCount TotalRoomCount ,@AvailableRooms AvailableRooms

			SET @AvailableRooms = ISNULL(@TotalRoomCount, 0) - ISNULL(@reservedRooms, 0);
            SELECT ISNULL(@TotalRoomCount, 0) AS TotalRoomCount, ISNULL(@AvailableRooms, 0) AS AvailableRooms;

			SELECT Distinct PIT.ItemID,ItemCode,ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult
			--, AVG(PRP.SalePrice) SalePrice      -- Added BY Somnath
			FROM Products.Item PIT
			--inner join Products.RoomPrice PRP on PIT.ItemID=PRP.ItemID 
			--AND (PRP.FromDate>= @ExpectedCheckInDate And PRP.FromDate<=@ExpectedCheckOutDate)   -- Added BY Somnath
			WHERE SubCategoryID=@SubCategoryID and IsActive=1
			Group By PIT.ItemID,ItemCode,ItemName
			
		END
		ELSE
		BEGIN

		--Begin Commented by Arabinda on 2023-09-27 to get the counts from subcategory tables------------------
			--select @TotalRoomCount=COUNT(RoomNo) 
			--from Products.Room RM
			--inner join [Products].[SubCategory] SC on RM.SubCategoryID = SC.SubCategoryID
			--inner join [Products].[Item] IT on SC.SubCategoryID = IT.SubCategoryID
			--Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
			--where RM.SubCategoryID=@SubCategoryID and RM.MaxAdultCapacity>=@NoOfAdults/@NoOfRooms and RM.MaxChildCapacity>=@NoOfChild/@NoOfRooms
			--  and GC.GuestCompanyID = @CompanyID

			select @TotalRoomCount=ps.TotalInventory From Products.subcategory ps where SubCategoryID=@SubCategoryID
			
			---------------End------------------------
			 
			--select @reservedRooms= count (RR.ReservationID)  
			--from reservation.Reservation RR
			--inner join reservation.ReservationDetails RD on RD.ReservationID=RR.ReservationID
			--inner join Products.Item IT on IT.ItemID=RD.ItemID
			--Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
			--where IT.SubCategoryID=@SubCategoryID and RR.ReservationStatusID in(1,3)
			--and (@ExpectedCheckInDate BETWEEN ExpectedCheckIn AND ExpectedCheckOut OR @ExpectedCheckOutDate BETWEEN ExpectedCheckIn AND ExpectedCheckOut)
			--and GC.GuestCompanyID = @CompanyID

			SELECT @reservedRooms = COUNT(*)
				FROM (
					SELECT RD.ItemID, RR.ReservationID
					FROM reservation.Reservation RR
					INNER JOIN reservation.ReservationDetails RD ON RD.ReservationID = RR.ReservationID
					INNER JOIN Products.Item IT ON IT.ItemID = RD.ItemID
					--Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
					WHERE IT.SubCategoryID = @SubCategoryID  AND RR.ReservationStatusID IN (1, 3, 12, 15)--Reserved, IN-House,Requested,No Show
					 AND (@ExpectedCheckInDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut) OR 
					 @ExpectedCheckOutDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut))
					-- and GC.GuestCompanyID = @CompanyID
					GROUP BY RD.ItemID, RR.ReservationID
				) T;

		
			set  @AvailableRooms=@TotalRoomCount-@reservedRooms 
			select @TotalRoomCount TotalRoomCount ,@AvailableRooms AvailableRooms

			SELECT distinct IT.ItemID,IT.ItemCode,IT.ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult
			--, AVG(PRP.SalePrice) SalePrice    -- Added BY Somnath
			FROM Products.Item IT
			Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
			--inner join Products.RoomPrice PRP on IT.ItemID=PRP.ItemID 
			--AND (PRP.FromDate>= @ExpectedCheckInDate And PRP.FromDate<=@ExpectedCheckOutDate)   -- Added BY Somnath
			WHERE SubCategoryID=@SubCategoryID and GC.GuestCompanyID = @CompanyID	and it.IsActive=1 and GC.IsActive=1
			Group BY IT.ItemID,IT.ItemCode,IT.ItemName
		END

		SELECT min(StandardReservationDepositPercent) as RequiredReservationDeposit FROM  [reservation].[StandardReservationDeposit] 
			where  @DateDifference >=ReservationDayFrom and @DateDifference <=ReservationDayTo
			--@DateDifference BETWEEN ReservationDayFrom and ReservationDayTo
			
END

