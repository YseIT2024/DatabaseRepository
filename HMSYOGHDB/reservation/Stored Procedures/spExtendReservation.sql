
CREATE PROCEDURE [reservation].[spExtendReservation] --6543,'2024-01-26T11:55:00.00','2024-01-27T11:55:00.000',1,1,85,1,1
(
	@ReservationID INT,
    @CheckInDate DATETIME,
    @CheckOutDate DATETIME,
    @Nights INT,
    @LocationID INT,
    @UserID INT,
    @DrawerID INT,
	@IsNewPrice int =0
    --@dtProducts [reservation].[dtProductsRates] readonly
)
AS
BEGIN
    SET XACT_ABORT ON;

 
	DECLARE @UnAvailableRoomNumbers varchar(50)   
	exec Reservation.CheckIfRoomAvailableForExtension @ReservationId,@CheckInDate,@CheckOutDate,@UnAvailableRoomNumbers output
	if(@UnAvailableRoomNumbers!='available')
	BEGIN
		SELECT 0 AS [IsSuccess], 'Room(s) '+ @UnAvailableRoomNumbers +' Not Availalbe For Extension, Please check availablity!' AS [Message], -1 AS [ReservationID]
	return
	END

	DECLARE @Last_ReservationID int=6560;


    DECLARE @Count INT;
    DECLARE @ItrItem INT = 1;
    DECLARE @NoOfAdults INT;
    DECLARE @NoOfChildren INT;
    DECLARE @NoOfRooms INT;
    DECLARE @ItemID INT;
    DECLARE @Discount DECIMAL(18, 4);
    DECLARE @TotalTax DECIMAL(18, 4);
	DECLARE @IsSuccess BIT = 0;
    DECLARE @Message VARCHAR(MAX) = '';

    DECLARE @TotalAmountBeforeTax DECIMAL(18, 4);
    DECLARE @TotalTaxAmount DECIMAL(18, 4);
    DECLARE @TotalAmountAfterTax DECIMAL(18, 4);

    DECLARE @ExAdult INT = 0, @ExChild INT = 0;

    DECLARE @Name VARCHAR(200);
    DECLARE @Date VARCHAR(15);
    DECLARE @RsID INT;
    DECLARE @DiscountID DECIMAL(18, 4) = NULL;
    DECLARE @TotalNights INT;
    DECLARE @TaxRate DECIMAL(5, 2) = 0.10; -- Tax rate is set to 10%
    DECLARE @FromDate DATETIME = @CheckInDate;
    DECLARE @ExtraChildrenSr INT = 0;
    DECLARE @ExChildSr INT = 0;
    DECLARE @CompanyID INT = 0;
	DECLARE @startdate DATE;
	DECLARE @tempItems TABLE (ID INT IDENTITY(1, 1), ItemID INT, Rooms INT, Adults INT, Children INT, Discount DECIMAL, TotalTax DECIMAL)

    BEGIN
        TRY
            BEGIN TRANSACTION
			DECLARE @TempDates TABLE (startdate DATE);
            SET @CompanyID = (SELECT CompanyTypeID FROM [reservation].[Reservation] WHERE ReservationID = @ReservationID)
				
			INSERT INTO @tempItems
			SELECT DISTINCT ItemID, Rooms, Adults, Children, Discount, TotalTax FROM [reservation].[ReservationDetails] WHERE [ReservationID] = @ReservationID;

   
            IF (@IsNewPrice=0)
			BEGIN
                 
                WITH cte (startdate)
                AS
                (
                    SELECT @CheckInDate AS startdate
                    UNION ALL
                    SELECT DATEADD(DAY, 1, startdate) AS startdate
                    FROM cte
                    WHERE startdate < DATEADD(DAY, -1, @CheckOutDate)
                )
                INSERT INTO @TempDates
                SELECT startdate FROM cte;

                

                DECLARE myCursor CURSOR FOR
                    SELECT startdate FROM @TempDates;

                OPEN myCursor;
                FETCH NEXT FROM myCursor INTO @startdate;

                WHILE @@FETCH_STATUS = 0
                BEGIN                 
                        BEGIN
                            INSERT INTO [reservation].[ReservationDetails] (ReservationID, ItemID, NightDate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax,TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage)
                            SELECT TOP 1 ReservationID, ItemID, @startdate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax, TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID
                            SET @ItrItem = @ItrItem + 1;
                        END
                    FETCH NEXT FROM myCursor INTO @startdate;
                END

                CLOSE myCursor;
                DEALLOCATE myCursor;
            END
			ELSE -- New Price
			BEGIN

				DECLARE @IntExAdult int=0;
				DECLARE @IntExChild int=0; 
				DECLARE @IntExChildSr int=0;
				DECLARE @DiscountPercentage decimal (18,4)=0;

				SELECT TOP 1  
				@IntExAdult=ExtraAdults,
				@IntExChild=ExtraChildren,
				@IntExChildSr=ExtraChildrenSr,
				@DiscountPercentage=DiscountPercentage 
				FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID

				--To Get price from rate master				
				IF (@CompanyID = 0)  --Guest booking
						BEGIN
							IF(@ReservationID < @Last_ReservationID) --Guest  Old Table Master
								BEGIN
										SET @TotalNights = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);

									 
										SELECT @Count = COUNT(*) FROM @tempItems

										BEGIN
												SELECT @ItemID = ItemID, @NoOfRooms = Rooms, @NoOfAdults = Adults, @NoOfChildren = Children, @Discount = Discount, @TotalTax = TotalTax FROM @tempItems WHERE ID = @ItrItem

												INSERT INTO [reservation].[ReservationDetails] (ReservationID, ItemID, NightDate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax,
												TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage)

												SELECT
												@ReservationID AS ReservationID,
												PRP.ItemID,PRP.FromDate,@NoOfRooms AS Rooms,@NoOfAdults AS Adults,0 AS ExtraAdults,@NoOfChildren AS Children,
												0 AS ExtraChildren,@ExtraChildrenSr AS ExtraChildrenSr,

												case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END AS UnitPriceBeforeDiscount,
												@Discount AS Discount,
												case when isnull(@DiscountPercentage,0)>0 then
												(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) - 
												((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) * (@DiscountPercentage/100))
												else 
												case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice end
												end  as UnitPriceAfterDiscount,
												(GT.TaxRate) AS TotalTaxRate,
											
											  
												@NoOfRooms*((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END)-
												(((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END)) / ( 1+ (GT.TaxRate))))*GT.TaxRate/100
												AS TotalTaxAmount,
	 
												case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END AS UnitPriceAfterTax,
												case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END *  @NoOfRooms AS LineTotal
												,0
												FROM
												Products.Item PIT
												INNER JOIN Products.RoomPrice PRP ON PRP.ItemID = PIT.ItemID
												INNER JOIN Products.SubCategory SUB ON SUB.SubCategoryID = PIT.SubCategoryID
												LEFT JOIN Products.Room PR ON PR.SubCategoryID = SUB.SubCategoryID
												INNER JOIN Products.Tax PT ON PIT.ItemID = PT.ItemID
												INNER JOIN general.Tax GT ON GT.TaxID = PT.TaxID
												WHERE
												PIT.ItemID = @ItemID AND PRP.FromDate BETWEEN CONVERT(VARCHAR(10), @CheckInDate, 111) AND DATEADD(DAY, -1, CONVERT(VARCHAR(10), @CheckOutDate, 111))
												GROUP BY
												PRP.ItemID, PRP.FromDate, PRP.SalePrice, Discount, GT.TaxRate,prp.AddChild,prp.AddPax,prp.AddChildSr
												ORDER BY
												PRP.ItemID;
									 END
								END
							ELSE
								BEGIN --Guest  New Table Master
								SET @TotalNights = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);

									INSERT INTO @tempItems
									SELECT DISTINCT ItemID, Rooms, Adults, Children, Discount, TotalTax FROM [reservation].[ReservationDetails] WHERE [ReservationID] = @ReservationID

									SELECT @Count = COUNT(*) FROM @tempItems

									-- GET DETAILS
									 
									
									BEGIN
										SELECT @ItemID = ItemID, @NoOfRooms = Rooms, @NoOfAdults = Adults, @NoOfChildren = Children, @Discount = Discount, @TotalTax = TotalTax FROM @tempItems WHERE ID = @ItrItem

										INSERT INTO [reservation].[ReservationDetails] (ReservationID, ItemID, NightDate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax,
										TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage)

										SELECT
										@ReservationID AS ReservationID,
										PRP.ItemID,PRP.FromDate,@NoOfRooms AS Rooms,@NoOfAdults AS Adults,@IntExAdult AS ExtraAdults,@NoOfChildren AS Children,
										@IntExChild AS ExtraChildren,@IntExChildSr AS ExtraChildrenSr,
										
										case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END AS UnitPriceBeforeDiscount,
										(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) AS Discount,
										(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) AS UnitPriceAfterDiscount,
										(GT.TaxRate) AS TotalTaxRate,
										@NoOfRooms*(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)AS TotalTaxAmount,
										((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) AS UnitPriceAfterTax,
										((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) * @NoOfRooms AS LineTotal
										,@DiscountPercentage
										FROM
										Products.Item PIT
										INNER JOIN Products.RoomPriceNew PRP ON PRP.ItemID = PIT.ItemID
										INNER JOIN Products.SubCategory SUB ON SUB.SubCategoryID = PIT.SubCategoryID
										INNER JOIN Products.Tax PT ON PIT.ItemID = PT.ItemID
										INNER JOIN general.Tax GT ON GT.TaxID = PT.TaxID
										WHERE
										PIT.ItemID = @ItemID AND PRP.FromDate BETWEEN CONVERT(VARCHAR(10), @CheckInDate, 111) AND DATEADD(DAY, -1, CONVERT(VARCHAR(10), @CheckOutDate, 111))
										AND PRP.IsApproved=1
										GROUP BY
										 PRP.FromDate, PRP.SalePrice, Discount, GT.TaxRate,prp.AddPax,prp.AddChild,prp.AddChildSr,PRP.BasePrice,PRP.ItemID
										ORDER BY
										PRP.ItemID;
									END

								
					  END
					END
				ELSE  --Company Booking old Master
				BEGIN
				IF (@ReservationID < @Last_ReservationID)
					BEGIN     --Get from old company rate master table
					
							SELECT @ItemID = ItemID, @NoOfRooms = Rooms, @NoOfAdults = Adults, @NoOfChildren = Children, @Discount = Discount, @TotalTax = TotalTax FROM @tempItems WHERE ID = @ItrItem;

							WITH cte (startdate)
							AS
							(
								SELECT @CheckInDate AS startdate
								UNION ALL
								SELECT DATEADD(DAY, 1, startdate) AS startdate
								FROM cte
								WHERE startdate < DATEADD(DAY, -1, @CheckOutDate)
							)

							INSERT INTO @TempDates
							SELECT startdate FROM cte;

							DECLARE myCursor CURSOR FOR
							SELECT startdate FROM @TempDates;

							OPEN myCursor;
							FETCH NEXT FROM myCursor INTO @startdate;

							WHILE @@FETCH_STATUS = 0
								BEGIN                 
                       
										INSERT INTO [reservation].[ReservationDetails] (ReservationID, ItemID, NightDate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax,TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage)

										(SELECT 
										@ReservationID,@ItemID,@startdate,@NoOfRooms,@NoOfAdults,@IntExAdult,@NoOfChildren,@IntExAdult,@IntExChildSr,
										case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END  as UnitPriceBeforeDiscount, 
										GC.DiscountPercent as Discount, 
										case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END  as UnitPriceAfterDiscount, 

										isnull(sum(GT.TaxRate),0) as TotalTax,
										@NoOfRooms * ISNULL((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) / ( 1+ sum(GT.TaxRate)),0) as TotalTaxAmount, 

										case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END as UnitPriceAfterTax,
										(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) * @NoOfRooms as  LineTotal,
						
										0 as DiscountPercentage 
										from Products.Item PIT
										inner join [guest].[GuestCompanyRateContract] GC on PIT.ItemID = GC.ItemID
										inner join Products.SubCategory SUB on SUB.SubCategoryID=PIT.SubCategoryID
										inner join Products.Tax PT on PIT.ItemID=PT.ItemID
										inner join general.Tax GT on GT.TaxID=PT.TaxID
										where
										ContractFrom<= CONVERT(VARCHAR(10),@CheckInDate,111) AND ContractTo >= CONVERT(VARCHAR(10),@CheckOutDate,111) 
										and GC.GuestCompanyID = @CompanyID and PIT.ItemID=@itemId
										group by  GC.ItemID,ItemName,Name,SUB.SubCategoryID,GC.ContractFrom,GC.SellRate,GC.DiscountPercent,GC.AddPax,GC.AddChild,GC.AddChildSr)

										FETCH NEXT FROM myCursor INTO @startdate;
								END

							CLOSE myCursor;
							DEALLOCATE myCursor;

					END
					Else     --Get from new company rate master table
					BEGIN
					
							SET @TotalNights = DATEDIFF(DAY, @CheckInDate, @CheckOutDate);

							INSERT INTO @tempItems
							SELECT DISTINCT ItemID, Rooms, Adults, Children, Discount, TotalTax FROM [reservation].[ReservationDetails] WHERE [ReservationID] = @ReservationID

							SELECT @Count = COUNT(*) FROM @tempItems

							-- GET DETAILS
							SELECT @ItemID = ItemID, @NoOfRooms = Rooms, @NoOfAdults = Adults, @NoOfChildren = Children, @Discount = Discount, @TotalTax = TotalTax FROM @tempItems WHERE ID = @ItrItem

							INSERT INTO [reservation].[ReservationDetails] (ReservationID, ItemID, NightDate, Rooms, Adults, ExtraAdults, Children, ExtraChildren, ExtraChildrenSr, UnitPriceBeforeDiscount, Discount, UnitPriceAfterDiscount, TotalTax,
							TotalTaxAmount, UnitPriceAfterTax, LineTotal,DiscountPercentage)

							SELECT
							@ReservationID AS ReservationID,
							PRP.ItemID,PRP.FromDate,@NoOfRooms AS Rooms,@NoOfAdults AS Adults,0 AS ExtraAdults,@NoOfChildren AS Children,
							0 AS ExtraChildren,@ExtraChildrenSr AS ExtraChildrenSr,
										
							case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END AS UnitPriceBeforeDiscount,
							(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) AS Discount,
							(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) AS UnitPriceAfterDiscount,
							(GT.TaxRate) AS TotalTaxRate,
							@NoOfRooms*(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)AS TotalTaxAmount,
							((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) AS UnitPriceAfterTax,
							((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) * @NoOfRooms AS LineTotal,
							@DiscountPercentage
							FROM
							Products.Item PIT
							INNER JOIN company.RoomPriceNew PRP ON PRP.ItemID = PIT.ItemID
							INNER JOIN Products.SubCategory SUB ON SUB.SubCategoryID = PIT.SubCategoryID
										 
							INNER JOIN Products.Tax PT ON PIT.ItemID = PT.ItemID
							INNER JOIN general.Tax GT ON GT.TaxID = PT.TaxID
							WHERE
							PIT.ItemID = @ItemID AND PRP.FromDate BETWEEN CONVERT(VARCHAR(10), @CheckInDate, 111) AND DATEADD(DAY, -1, CONVERT(VARCHAR(10), @CheckOutDate, 111))
							GROUP BY PRP.ItemID,PRP.FromDate,PRP.BasePrice,prp.AddPax,prp.AddChild,prp.AddChildSr,GT.TaxRate

					END
				END
			END

            SET @TotalAmountBeforeTax = (SELECT SUM(UnitPriceAfterDiscount) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP BY ReservationID)

            SET @TotalTaxAmount = (SELECT SUM(TotalTaxAmount) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP BY ReservationID)

            UPDATE [reservation].[Reservation]
            SET [ExpectedCheckOut] = @CheckOutDate,
                [Nights] = [Nights] + @Nights,
                TotalAmountBeforeTax = @TotalAmountBeforeTax,
                TotalTaxAmount = @TotalTaxAmount,
                TotalAmountAfterTax = @TotalAmountBeforeTax + @TotalTaxAmount,
                --TotalPayable = (@TotalAmountBeforeTax + @TotalTaxAmount) - AdditionalDiscountAmount
				TotalPayable=(SELECT SUM(LineTotal) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP BY ReservationID)
            WHERE [ReservationID] = @ReservationID AND LocationID = @LocationID

            DECLARE @Folio VARCHAR(50);
            DECLARE @Guest VARCHAR(200);

            SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
            FROM reservation.Reservation r
            INNER JOIN general.Location l ON r.LocationID = l.LocationID
            INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
            INNER JOIN contact.Details d ON g.ContactID = d.ContactID
            WHERE r.ReservationID = @ReservationID

            DECLARE @Drawer VARCHAR(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
            DECLARE @Title VARCHAR(200) = 'Extend Reservation for Reservation ID: ' + CAST(@ReservationID as varchar(12)) + ' . ' + @Guest + '(' + @Folio + ')' 
			+ '  has been completed  successfully for' + CAST(@Nights AS VARCHAR) + ' night(s)'
            DECLARE @NotDesc VARCHAR(MAX) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID AS VARCHAR(10));
            EXEC [dbo].[spInsertIntoNotification] @LocationID, @Title, @NotDesc
            COMMIT TRANSACTION

            SET @IsSuccess = 1; --success
            SET @Message = 'The reservation has been extended successfully.';

			EXEC [app].[spInsertActivityLog] 34, @LocationID, @NotDesc, @UserID,@Message
        END TRY
        BEGIN CATCH

            IF (XACT_STATE() = -1)
            BEGIN
                ROLLBACK TRANSACTION;

                SET @Message = ERROR_MESSAGE();
                SET @IsSuccess = 0; --error
                SET @ReservationID = -1; --error
            END;

            IF (XACT_STATE() = 1)
            BEGIN
                COMMIT TRANSACTION;

                SET @IsSuccess = 1; --success
                SET @Message = 'The reservation has been extended successfully.';
            END;

            -- Insert into activity log
            DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());
            EXEC [app].[spInsertActivityLog] 34, @LocationID, @Act, @UserID
        END CATCH;

        SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @ReservationID AS [ReservationID]
    END

