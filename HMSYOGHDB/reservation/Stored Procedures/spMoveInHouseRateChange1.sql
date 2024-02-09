
CREATE PROCEDURE [reservation].[spMoveInHouseRateChange1] --10,25,849,'2023-12-30 14:00:00.000','2024-01-02 11:55:00.000',0.00,'2023-12-30 11:55:00.000','change Room',1,1,76,0
(
	@NewRoomID INT,	
	@OldRoomID INT,
	@ReservationID INT,
	@CheckInDate DATE,
	@CheckOutDate DATE,	
	@RoomChangeAmount DECIMAL(18,3),
	@RoomChangeDate DATE,	
	@Reason VARCHAR(MAX),
	@LocationID INT,
	@DrawerID INT,
	@UserID INT,	
	--@dtRate as reservation.dtRoomRate READONLY,
	@isWriteOffTransaction BIT,

	@ItemId int =0,
	@OldAmount DECIMAL(18,3)=0,
	@NewAmount DECIMAL(18,3)=0,
	@DifferenceAmount DECIMAL(18,3)=0,
	@OldItemId int =0,
	@changePriceorNot bit =0



	
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON; 
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @ReservedRoomID int;	
	DECLARE @CheckOutDateId int = (SELECT CAST(FORMAT(@CheckOutDate,'yyyyMMdd') as int));
	DECLARE @RoomChangeDateID int = (SELECT CAST(FORMAT(@RoomChangeDate,'yyyyMMdd') as int));
	DECLARE @OldRoom int;
	DECLARE @NewRoom int;
	DECLARE @RateCurrencyID int;
	DECLARE @ReservationStatusID int;
	DECLARE @ReservationTypeID int;
	DECLARE @GuestID int;
	DECLARE @dtRoom as [reservation].[dtRoom];
	DECLARE @AccountingDateID int;
	DECLARE @Drawer varchar(20);
	DECLARE @Title varchar(200);
	DECLARE @NotDesc varchar(max);

	DECLARE @OldSubCategory int=0;	
	DECLARE @NewSubCategory int=0;

	

	SELECT @ReservationStatusID = ReservationStatusID, @ReservationTypeID = ReservationTypeID, @GuestID = GuestID
	FROM reservation.Reservation	WHERE ReservationID = @ReservationID	

	INSERT INTO @dtRoom (RoomID)
	VALUES(@NewRoomID);	
	
	SET @OldSubCategory =	(select SubCategoryID from Products.Item WHERE ItemID=@OldItemId)
	SET @NewSubCategory =(select SubCategoryID from Products.Item WHERE ItemID=@ItemId)


	--IF (@ReservationStatusID <> 1 OR @ReservationStatusID <> 3) --Status IN House
	--	BEGIN
	--		SET @IsSuccess = 0; 
	--		SET @Message = 'Reservation status has been changed from outside! Please refresh the page and try again!';
	--	END
	--ELSE IF EXISTS(SELECT tRooms.RoomID FROM (SELECT * FROM [room].[fnCheckIfRoomAvailable](@RoomChangeDateID,@CheckOutDateId,@dtRoom)) tRooms WHERE tRooms.RoomID = @NewRoomID AND tRooms.ReservationID <> @ReservationID)
	--	BEGIN
		
	--		SET @IsSuccess = 0;
	--		SET @Message = 'Selected room is not available! Please refresh the page and try again!';
	--		--insert into TestTable(columnName)values ('A')
	--	END
	--CREATE TABLE TestTable (ColumnName VARCHAR(255))
	--DELETE FROM TestTable;
	
	 IF(@NewRoomID = (SELECT top 1 [RoomID] FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID AND RoomID=@OldRoomID AND  IsActive = 1))
		BEGIN
	
			DECLARE @RoomNo varchar(10) = 
			(
				SELECT CAST
				((
				--SELECT Room FROM [reservation].[ReservedRoom]  where RoomID=@OldRoomID aND ReservationID = @ReservationID
					SELECT  r.RoomNo FROM [reservation].[ReservedRoom] rr 
					INNER JOIN Products.Room r ON rr.RoomID = r.RoomID
					WHERE ReservationID = @ReservationID AND rr.IsActive = 1 AND rr.RoomID=@OldRoomID
				) as varchar(10))
			);
			SET @IsSuccess = 0; 
			SET @Message = 'The reservation has already been shifted to Room no <b>' + @RoomNo + '</b>! Please refresh the page.';
		END
	ELSE
		BEGIN TRY
			BEGIN TRANSACTION	
			
				SELECT @OldRoom = RoomNo, @RateCurrencyID = RateCurrencyID, @ReservedRoomID = ReservedRoomID
				FROM [reservation].[ReservedRoom] rm 
				INNER JOIN Products.Room r ON rm.RoomID = r.RoomID 
				WHERE rm.ReservationID = @ReservationID AND rm.roomid= @OldRoomID AND rm.IsActive = 1

				SET @NewRoom = (SELECT RoomNo FROM Products.Room WHERE RoomID = @NewRoomID);
				DECLARE @DiscountId INT= (SELECT TOP 1 DiscountID FROM [reservation].[RoomRate] WHERE ReservedRoomID = @ReservedRoomID);

				

				if (@ReservationStatusID=3)  -- Status change is required only if inhouse Added by Arabinda on 14-12-2023
					begin 

						DELETE FROM [reservation].[RoomRate] 
						WHERE ReservedRoomID = @ReservedRoomID AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						DELETE FROM guest.GuestWallet
						WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						UPDATE [reservation].[ReservedRoom]
						SET IsActive = 0	
						,UserID = @UserID
						,ModifiedDate = GETDATE()
						WHERE ReservedRoomID = @ReservedRoomID AND IsActive = 1

						--UPDATE [Products].[Room] set RoomStatusID=3 where RoomID=@OldRoomID
						--UPDATE [Products].[Room] set RoomStatusID=5 where RoomID=@NewRoomID

						UPDATE [Products].[RoomLogs] --[room].[RoomStatusHistory]
						SET ToDate = @RoomChangeDate
						,ToDateID = @RoomChangeDateID
						,RoomStatusID = 8
						,IsPrimaryStatus = 0				
						,CreatedBy = @UserID
						WHERE [ReservationID] = @ReservationID AND RoomID = @OldRoomID AND IsPrimaryStatus = 1	

						INSERT INTO [reservation].[ReservedRoomLog]
						([ReservationID],[RoomID],[Date],[UserID])
						VALUES(@ReservationID, @NewRoomID, GETDATE(), @UserID)

						INSERT INTO [Products].[RoomLogs]--[room].[RoomStatusHistory]
						([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[ReservationID],[CreatedBy])	
						VALUES(@NewRoomID, FORMAT(@RoomChangeDate, 'yyyyMMdd'), @CheckOutDateId, 5, 1, @RoomChangeDate, @CheckOutDate, @ReservationID, @UserID)			

						INSERT INTO [reservation].[ReservedRoom]
						([ReservationID],[RoomID],[StandardCheckInOutTimeID],[IsActive],[RateCurrencyID], [ModifiedDate], [UserID],ShiftedRoomID)
						VALUES(@ReservationID, @NewRoomID, 1, 1, 1, GETDATE(), @UserID,@OldRoomID)	
				
						SET @ReservedRoomID = SCOPE_IDENTITY();

						SET @AccountingDateID = (SELECT MAX(AccountingDateId) FROM account.AccountingDates WHERE DrawerID = @DrawerID)



						--if(@ItemId>0)
						--Begin
						--	Update RD Set ItemID=@ItemId
						--	From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId
						--End



						--IF(@ReservationTypeID = 7)	--HOUSE USE			
						--	BEGIN
						--		INSERT INTO [reservation].[RoomRate]
						--		([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
						--		SELECT @ReservedRoomID, r.DateID, 230, 0, 1
						--		FROM @dtRate r		
						--	END
						--ELSE
							--BEGIN
							--	INSERT INTO [reservation].[RoomRate]
							--	([ReservedRoomID], [DateID], [RateID], [Rate], [DiscountID])
							--	SELECT @ReservedRoomID, r.DateID, r.RateID, r.Amount, @DiscountId
							--	FROM @dtRate r		
							--END	

						--commented by Arabinda on 14-12-2023 as no use of wallet
						--INSERT INTO [guest].[GuestWallet]
						--([GuestID],[TransactionTypeID],[AccountTypeID],[ReservationID],[ReservedRoomRateID],[DateID],[Amount],[RateCurrencyID],[AccountingDateID],[TransactionDateTime],[Remarks])				
						--SELECT @GuestID, 1, 82, @ReservationID, rt.ReservedRoomRateID, rt.[DateID], (-1)*rt.Rate, @RateCurrencyID, @AccountingDateID, GETDATE(), 'Daily room charge.'
						--FROM Reservation.RoomRate rt 					
						--WHERE rt.ReservedRoomID = @ReservedRoomID
						----------------End---------------------------------

						INSERT INTO [reservation].[ReservationStatusLog]
						([ReservationID],[ReservationStatusID],[Remarks],[UserID],[DateTime])
						VALUES(@ReservationID, 7, @Reason + ', Moved reservation id- ' + CONVERT(VARCHAR, @ReservationID) +', From Room No- ' 
						+ CONVERT(VARCHAR, @OldRoom) + ' to Room No- ' + CONVERT(VARCHAR, @NewRoom) +'.', @UserID, GETDATE())		
								

					end
				Else
					begin

						DELETE FROM [reservation].[RoomRate] 
						WHERE ReservedRoomID = @ReservedRoomID AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');

						DELETE FROM guest.GuestWallet
						WHERE ReservationID = @ReservationID AND AccountTypeID = 82 AND DateID >= FORMAT(@RoomChangeDate, 'yyyyMMdd');
												

						UPDATE [reservation].[ReservedRoom]
						SET 
						RoomID=@NewRoomID						
						,UserID = @UserID
						,ModifiedDate = GETDATE()
						WHERE ReservationID=@ReservationID and  RoomID = @OldRoomID						
						
						UPDATE [Products].[RoomLogs] --[room].[RoomStatusHistory]
						SET RoomID=@NewRoomID
						,CreatedBy = @UserID
						,CreateDate=GETDATE()
						WHERE [ReservationID] = @ReservationID AND RoomID = @OldRoomID --AND IsPrimaryStatus = 1


						Update [reservation].[ReservedRoomLog] set
						roomid=@NewRoomID,
						Date=GETDATE()
						where ReservationID=@ReservationID and RoomID=@OldRoomID		
						
						--if(@ItemId>0)
						--Begin
						--	Update RD Set ItemID=@ItemId
						--	From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId
						--End
						
					end		
		
		
		--if(@ItemId>0 And @ItemId<>@OldItemId)
		IF(@OldSubCategory<>@NewSubCategory)
		Begin
			if((Select top 1 Rooms From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId)>1)
			Begin
				UPDATE [reservation].[ReservationDetails]
				   SET
				 [Rooms] = [Rooms]-1
				,[UnitPriceBeforeDiscount]= [UnitPriceBeforeDiscount] *([Rooms]-1)/[Rooms]
				,[UnitPriceAfterDiscount] =[UnitPriceAfterDiscount]   *([Rooms]-1)/[Rooms]
				,[TotalTaxAmount] = 		 [TotalTaxAmount]  *([Rooms]-1)/[Rooms]
				,[UnitPriceAfterTax] = 	 [UnitPriceAfterTax]  *([Rooms]-1)/[Rooms]
				,[LineTotal] = 			 [LineTotal]  *([Rooms]-1)/[Rooms]      
				where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId;

				INSERT INTO [reservation].[ReservationDetails]          
				([ReservationID]           ,[ItemID]           ,[NightDate]           ,[Rooms]           
				,[Adults]           ,[ExtraAdults]           ,[Children]           ,[ExtraChildren]
			   ,[UnitPriceBeforeDiscount]           ,[Discount]           ,[UnitPriceAfterDiscount]
			   ,[TotalTax]           ,[TotalTaxAmount]           ,[UnitPriceAfterTax]           ,[LineTotal]
			   ,[TaxDetailID]           ,[ExtraChildrenSr]           ,[DiscountPercentage])
				SELECT [ReservationID]      , @ItemId      ,[NightDate]      ,'1'
				  ,[Adults]      ,[ExtraAdults]      ,[Children]      ,[ExtraChildren]
				  ,[UnitPriceBeforeDiscount] * (1/[Rooms] )     ,[Discount]      ,[UnitPriceAfterDiscount] * (1/[Rooms] ) 
				  ,[TotalTax]      ,[TotalTaxAmount]  * (1/[Rooms] )      ,[UnitPriceAfterTax]  * (1/[Rooms] )     ,[LineTotal] * (1/[Rooms] ) 
				  ,[TaxDetailID]      ,[ExtraChildrenSr]      ,[DiscountPercentage]
				FROM [HMSYOGH].[reservation].[ReservationDetails] where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId;
			End
			Else 
			Begin
			Update RD Set ItemID=@ItemId
			From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId
			End		
		End
		Else 
		Begin
			Update RD Set ItemID=@ItemId
			From reservation.ReservationDetails RD where ReservationID=@ReservationID AND NightDate >= Convert(Date,@RoomChangeDate) and itemid=@OldItemId
		End

				if(@changePriceorNot=1)
				Begin
				Declare @TempDateTable Table ([Date] date)

				DECLARE @MinDate DATE = (Select Case when @RoomChangeDate> @CheckInDate Then @RoomChangeDate Else @CheckInDate End ),
						@MaxDate DATE = @CheckOutDate;
					
				Insert into @TempDateTable
				SELECT  TOP (DATEDIFF(DAY, @MinDate, @MaxDate) + 1)
				Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @MinDate)
				FROM    sys.all_objects a
				CROSS JOIN sys.all_objects b;

				While Exists(Select * From @TempDateTable WHere Convert(Date,[Date]) = Convert(Date,@MinDate))
				Begin
					Update 	RD  Set 
					RD.UnitPriceBeforeDiscount = PRP.SalePrice , RD.UnitPriceAfterDiscount = PRP.SalePrice- RD.Discount,
					RD.TotalTaxAmount = PRP.SalePrice- (PRP.SalePrice/1.1),					
					RD.UnitPriceAfterTax = PRP.SalePrice, RD.LineTotal = PRP.SalePrice*Rd.Rooms

					From [reservation].[ReservationDetails] RD --Where RD. ReservationID= @ReservationID And NightDate= @MinDate
					Inner Join  Products.Item PIT ON PIT.ItemID= RD.ItemID 
					inner join Products.RoomPrice PRP on PIT.ItemID=PRP.ItemID AND FromDate = @MinDate
					Where RD. ReservationID= @ReservationID And NightDate= @MinDate --and RD.itemid=@ItemId

						Set @MinDate= DATEADD(DAY,1,@MinDate)
				End

					Declare @COuntDetails int= (Select Count(*) From reservation.Reservation r Join reservation.ReservationDetails rd on rd.ReservationID= r.ReservationID Where r.ReservationID=@ReservationID)

					Declare   @TotalAmountBeforeTax Decimal(10,4) 
							 ,@TotalTaxAmount Decimal(10,4)
							 ,@TotalAmountAfterTax Decimal(10,4)
							 ,@AdditionalDiscount Decimal(10,4)
							 ,@AdditionalDiscountAmount Decimal(10,4)
							 ,@TotalPayable  Decimal(10,4) 

					 Select    @TotalAmountBeforeTax = Sum(RD.[UnitPriceAfterDiscount])
							  ,@TotalTaxAmount= Sum(RD.[TotalTaxAmount])
							  ,@TotalAmountAfterTax  = Sum(RD.[UnitPriceAfterTax])
							  ,@AdditionalDiscount = RD.[Discount]
							  ,@AdditionalDiscountAmount  =SUM(RD.[UnitPriceBeforeDiscount]) - SUM(RD.[UnitPriceAfterDiscount])
							  ,@TotalPayable   = Sum(RD.[LineTotal])  From  [reservation].[ReservationDetails] RD  
							  WHERE RD.ReservationID = @ReservationID 
							  Group By RD.[Discount]; 
       
						UPDATE R
						SET
							R.TotalAmountBeforeTax = @TotalAmountBeforeTax
							,R.[TotalTaxAmount] = @TotalTaxAmount
							,R.[TotalAmountAfterTax] = @TotalAmountAfterTax
							,R.[AdditionalDiscount] = @AdditionalDiscount
							,R.[AdditionalDiscountAmount] = @AdditionalDiscountAmount
							,R.[TotalPayable] = @TotalPayable
							From [reservation].[Reservation] R
							join  [reservation].[ReservationDetails] RD On RD.ReservationID=R.ReservationID
						WHERE R.ReservationID = @ReservationID;  
				

				End
						
				SET @IsSuccess = 1; --success
				SET @Message = 'The reservation has been moved to different room successfully.';
				

				DECLARE @Folio varchar(50); 
				DECLARE @Guest varchar(200);

				SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
				FROM reservation.Reservation r
				INNER JOIN general.Location l ON r.LocationID = l.LocationID
				INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
				INNER JOIN contact.Details d ON g.ContactID = d.ContactID
				WHERE r.ReservationID = @ReservationID

				DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
				
				SET  @Title  = 'Move Reservation: ' + @Guest + '(' + @Folio + ')' + ' reservation has moved from '
				+ CAST(@OldRoom as varchar) + ' to ' + CAST(@NewRoom as varchar) + ' Room No'
				SET  @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
				--EXEC [dbo].[spInsertIntoNotification] @LocationID, @Title, @NotDesc
			COMMIT TRANSACTION
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
				SET @Message = 'The reservation has been moved to different room successfully.';
			END;  
		
			---------------------------- Insert into activity log---------------	
			DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
			--EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
		END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]	
END

--Select * from [Products].[RoomLogs] where ReservationID=6672

--select * from reservation.ReservationDetails where ReservationID=846
--select * from [Products].[Item] where SubCategoryID=45 and IsActive=1
--select * from Products.SubCategory where CategoryID=1 and IsActive=1
--update reservation.ReservationDetails set ItemID=24 where reservationid=846

--select SC.Name, IT.ItemName, RD.NightDate,RD.Rooms, RD.LineTotal,RD.TotalTaxAmount,SC.SubCategoryID 
--from [reservation].[ReservationDetails] RD
--		INNER JOIN [Products].[Item] IT ON RD.ItemID = IT.ItemID
--		INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID
--		where rd.ReservationID=846
