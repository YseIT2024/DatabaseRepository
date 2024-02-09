CREATE PROCEDURE [reservation].[MoveInHOuseGetProductDetail] --45,'12/18/2023','12/21/2023',0,0,0,0
(	
	@SubCategoryID int,
	@ExpectedCheckInDate datetime,
	@ExpectedCheckOutDate datetime,
	@NoOfAdults int,
	@NoOfChild int,
	@NoOfRooms int,
	@CompanyID int,
	@ReservationId int
)
AS
BEGIN

Declare @LastReservationID int=1474;
Declare @IsNewQuery int=0;
if(@ReservationId > @LastReservationID)
	begin
		set @IsNewQuery=1;
	end

	set @CompanyID=(select CompanyTypeID from reservation.Reservation where ReservationID=@ReservationId)

		Declare @TotalRoomCount int,@reservedRooms int,@AvailableRooms int, @DateDifference int
		set @DateDifference=DATEDIFF(DAY,GETDATE(),@ExpectedCheckInDate)
		if(@IsNewQuery=0)
			begin   -- Old Query

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

			--SELECT  PIT.ItemID,ItemCode,ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult  --,SubCategoryID,PRP.SalePrice
			--, MAX(PRP.SalePrice) SalePrice , MAX(PRP.BasePrice) BasePrice      -- Added BY Somnath
			--FROM Products.Item PIT
			--inner join Products.RoomPrice PRP on PIT.ItemID=PRP.ItemID AND FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate  -- Added BY Somnath
			--WHERE SubCategoryID= @SubCategoryID 
			--and IsActive=1
			--Group By PIT.ItemID,ItemCode,ItemName
			--Order By PIT.ItemID
			
					SELECT distinct IT.ItemID,IT.ItemCode,IT.ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult
			 ,MAX(GC.SellRate) as SalePrice ,MAX(GC.SellRate) as BasePrice   -- Added BY Somnath
			FROM Products.Item IT
			Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
			--inner join Products.RoomPrice PRP on IT.ItemID=PRP.ItemID 
			--AND (PRP.FromDate>= @ExpectedCheckInDate And PRP.FromDate<=@ExpectedCheckOutDate)   -- Added BY Somnath
			WHERE SubCategoryID=@SubCategoryID and GC.GuestCompanyID = @CompanyID	and it.IsActive=1 and GC.IsActive=1
			Group BY IT.ItemID,IT.ItemCode,IT.ItemName
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
					, MAX(PRP.SalePrice) SalePrice, MAX(PRP.BasePrice) BasePrice    -- Added BY Somnath
					FROM Products.Item IT
					Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
					inner join Products.RoomPrice PRP on IT.ItemID=PRP.ItemID  AND FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate  
					WHERE SubCategoryID=@SubCategoryID and GC.GuestCompanyID = @CompanyID	
					and it.IsActive=1 and GC.IsActive=1
					Group BY IT.ItemID,IT.ItemCode,IT.ItemName

	

		END

		SELECT min(StandardReservationDepositPercent) as RequiredReservationDeposit FROM  [reservation].[StandardReservationDeposit] 
			where  @DateDifference >=ReservationDayFrom and @DateDifference <=ReservationDayTo
end
		else
			begin   -- New Query
		
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

				SELECT  PIT.ItemID,ItemCode,ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult  --,SubCategoryID,PRP.SalePrice
				,MAX(PRP.SalePrice) SalePrice 
				,MAX(PRP.SalePrice) BasePrice
				FROM Products.Item PIT
				inner join Products.RoomPriceNew PRP on PIT.ItemID=PRP.ItemID AND FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate
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
					--Inner join [guest].[GuestCompanyRateContract] GC on IT.ItemID = GC.ItemID
					WHERE IT.SubCategoryID = @SubCategoryID  AND RR.ReservationStatusID IN (1, 3, 12, 15)--Reserved, IN-House,Requested,No Show
					 AND (@ExpectedCheckInDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut) OR 
					 @ExpectedCheckOutDate BETWEEN CONVERT(date,ExpectedCheckIn) AND CONVERT(date,ExpectedCheckOut))
					-- and GC.GuestCompanyID = @CompanyID
					GROUP BY RD.ItemID, RR.ReservationID
				) T;

		
			set  @AvailableRooms=@TotalRoomCount-@reservedRooms 
			select @TotalRoomCount TotalRoomCount ,@AvailableRooms AvailableRooms
 
			SELECT  PIT.ItemID,ItemCode,ItemName,0 as RoomCount, 0 as Adult,0 as Child,0 as ExAdult  --,SubCategoryID,PRP.SalePrice
			,MAX(PRP.BasePrice) SalePrice , MAX(PRP.BasePrice) BasePrice  
			FROM Products.Item PIT
			inner join company.RoomPriceNew PRP on PIT.ItemID=PRP.ItemID AND 
			--FromDate Between @ExpectedCheckInDate AND @ExpectedCheckOutDate  -- Added BY Somnath
			PRP.FromDate between CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) and DATEADD(DAY,-1,CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111)) 
			WHERE SubCategoryID= @SubCategoryID 
			and PIT.IsActive=1
			Group By PIT.ItemID,ItemCode,ItemName
			Order By PIT.ItemID

		END

		SELECT min(StandardReservationDepositPercent) as RequiredReservationDeposit FROM  [reservation].[StandardReservationDeposit] 
			where  @DateDifference >=ReservationDayFrom and @DateDifference <=ReservationDayTo
end
			
END