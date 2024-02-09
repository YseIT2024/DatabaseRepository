CREATE PROCEDURE [reservation].[spDoCheckOut] 
(	
	@ReservationID int,
	@LocationID int,
	@UserID int,
	@DrawerID int,
	@CompanyID int,
	@keyReturned bit,
	@bellBoyID int,
	@guestID int,
	@CheckoutTime varchar(20),	
	@ResrvationStatusID int, --(Check out sub status)
	@DelayCharge bit,
	@ActualCheckOut datetime,
	@saleTypeID int=0
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON;  

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @StatusCode int = 0;
	DECLARE @CurrentDateId int;
	DECLARE @NextDayDateId int;		
	--DECLARE @ActualCheckOut datetime;
	DECLARE @ExpectedCheckOut datetime;
	DECLARE @RSHistoryID int;
	DECLARE @TotalAmountBeforeTax decimal(18, 4);
	DECLARE @TotalTaxAmount decimal(18, 4);
	DECLARE @TotalAmountAfterTax decimal(18, 4);
	DECLARE @TotalPayable decimal(18, 4);

	IF((SELECT ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND LocationID = @LocationID) = 3) --In House
		BEGIN					
			BEGIN TRY  
				BEGIN TRANSACTION
					
					--SET @ExpectedCheckOut = (SELECT ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID = @ReservationID)

					--IF(CONVERT(DATE,GETDATE()) > CONVERT(DATE,@ExpectedCheckOut))
					--BEGIN
					--	SET @ActualCheckOut = @ExpectedCheckOut;	
					--END
					--ELSE
					--BEGIN
					--	SET @ActualCheckOut = GETDATE();	
					--END

					--Concatenate the date with selected time
					--SET @ActualCheckOut = CONVERT(datetime, CONVERT(varchar, @ActualCheckOut, 112) + ' ' + @ActualCheckOut);
					SET @ActualCheckOut = CONVERT(datetime, @ActualCheckOut);
					SET @CurrentDateId = CAST(FORMAT(@ActualCheckOut,'yyyyMMdd') as int);
					SET @NextDayDateId = CAST(FORMAT(DATEADD(DAY,1,@ActualCheckOut),'yyyyMMdd') as int);

					UPDATE reservation.Reservation
					SET ReservationStatusID = 4 --Check Out
					,ActualCheckOut = @ActualCheckOut
					--,CompanyID = @CompanyID				
					WHERE ReservationID = @ReservationID

					SET @RSHistoryID = (SELECT MAX(RSHistoryID) FROM [Products].[RoomLogs] WHERE [ReservationID] = @ReservationID)

					UPDATE [Products].[Room]
					SET [RoomStatusID] = 8 where [RoomID] in (SELECT [RoomID] FROM [reservation].[ReservedRoom] where [ReservationID] = @ReservationID)

					UPDATE [Products].[RoomLogs]
					SET RoomStatusID = 8 --Checked Out
					,IsPrimaryStatus = 0
					,ToDate = @ActualCheckOut
					,ToDateID = @CurrentDateId
					--,ReservationID=@ReservationID
					WHERE ReservationID=@ReservationID   -- RSHistoryID = @RSHistoryID   -- Changed By Somnath

					--INSERT INTO [Products].[RoomLogs]
					--([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[CreatedBy],[CreateDate])	
					--SELECT RoomID, @CurrentDateId, @NextDayDateId, 8, 1, @ActualCheckOut, DATEADD(DAY,1,@ActualCheckOut), @UserID,GETDATE()
					--FROM [reservation].[ReservedRoom]
					--WHERE ReservationID = @ReservationID AND IsActive = 1

					SET @RSHistoryID = SCOPE_IDENTITY();

					INSERT INTO [todo].[ToDo]
					([ToDoTypeID],[LocationID],[DueDateTime],[Description],[EnteredOn],[EnteredBy],[RSHistoryID],[IsCompleted])
					Values(1, @LocationID, DATEADD(DAY,1,@ActualCheckOut), 'Housekeeping after Checked Out', GETDATE(), @UserID, @StatusCode, 0)

					INSERT INTO [reservation].[ReservationStatusLog]
					([ReservationID],[ReservationStatusID],[UserID],[DateTime],Remarks)
					VALUES(@ReservationID, 4, @UserID, GETDATE(),'Checked Out') ---4 Checked Out

					INSERT INTO [reservation].[CheckOutDetail]
					([ReservationID],[KeyReturned],[CreatedBy],[CreatedDate], [ReservationStatusID] )
					Values(@ReservationID, @keyReturned, @UserID, GETDATE(), @ResrvationStatusID)

					----------Add Bellboy details------------------------
											
					exec [guest].[usp_GuestLuggage_Insert] @ReservationID, @BellBoyID,@UserID,1,@GuestID,4 --Checkout
					----------------------------------------
					----------Update 1 day extra price for delayed check out------By--adding room count  +1 for each item (onlyfor last NightDate). Then calculate price accordingly
					if(@DelayCharge = 1)
						Begin

							update [reservation].[ReservationDetails]
									set Rooms = Rooms+1,
									TotalTaxAmount  = ((UnitPriceAfterDiscount * TotalTax)/100) * (Rooms+1),
									LineTotal = (UnitPriceAfterDiscount * (Rooms+1)) + (((UnitPriceAfterDiscount * TotalTax)/100) * (Rooms+1))
									WHERE ReservationID = @ReservationID 
									AND NightDate = (SELECT MAX(NightDate) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID); 

									--------------------
							SET @TotalAmountBeforeTax = (SELECT SUM(UnitPriceAfterDiscount) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP BY ReservationID)

							SET @TotalTaxAmount = (SELECT SUM(TotalTaxAmount) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP By ReservationID)

							SET @TotalPayable = (SELECT SUM(LineTotal) FROM [reservation].[ReservationDetails] WHERE ReservationID = @ReservationID GROUP By ReservationID)
				

							UPDATE [reservation].[Reservation] 
									SET TotalAmountBeforeTax = @TotalAmountBeforeTax,
									TotalTaxAmount =@TotalTaxAmount,
									TotalAmountAfterTax = @TotalAmountBeforeTax + @TotalTaxAmount,
									TotalPayable = @TotalPayable
									WHERE [ReservationID] = @ReservationID AND LocationID = @LocationID 	
						

						End


						-- Added By Vasanth
IF @CompanyID>0
	BEGIN

	IF (exists(SELECT CompanyID FROM guest.GuestCompany WHERE IsCredit=1 and IsActive=1 AND CompanyID=@CompanyID))
		BEGIN
			DECLARE @TotalReceivedAmount decimal(18,3);
			DECLARE @TotalAmount decimal(18,3);
			DECLARE @TotalPendingAmount decimal(18,3);
			DECLARE @FolioNumber int;
			--DECLARE @TotalIntrestAmount Decimal(18,3);
			DECLARE @IntrestPercentage int;
			DECLARE @CreditPeriod int;
			DECLARE @IntrestDate DATE;

			SELECT 
			@FolioNumber=FolioNumber 
			FROM reservation.Reservation WHERE ReservationID=@ReservationID

			set @TotalReceivedAmount =ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=@ReservationID),0);
			set @TotalAmount=ISNULL((SELECT sum(AmtAfterTax) FROM [account].[GuestLedgerDetails] where FolioNo=@FolioNumber),0)
			set @TotalPendingAmount=@TotalAmount-@TotalReceivedAmount;
			
			SELECT 
			@CreditPeriod=CreditPeriod,
			@IntrestPercentage=ISNULL(IntrestPercentageAfterCreditPeriod,0) 
			FROM guest.GuestCompany WHERE IsCredit=1 and CompanyID=@CompanyID

				IF(@TotalPendingAmount>0)
					BEGIN

						SET @IntrestDate = DATEADD(DAY, @CreditPeriod, @ActualCheckOut) 

						--SET @TotalIntrestAmount=(@TotalPendingAmount/100) *	 @IntrestPercentage

						INSERT INTO [reservation].[ReservationBalance]	
						([ReservationID],[CheckOutDate],[BalanceAmount],[CreditPeriod],[FollowupDate],[InterestPercentage],[CreatedDate])
						VALUES
						(@ReservationID,@ActualCheckOut,@TotalPendingAmount,@CreditPeriod,@IntrestDate,@IntrestPercentage,GETDATE())

					END
			END
	END				

	-- Insert Invoice Table 
	exec reservation.spCreateInvoice @ReservationID,@UserID

					------------------------------------

					Update [reservation].[Reservation] SET SalesTypeID=@saleTypeID where ReservationID=@ReservationID

					SET @IsSuccess = 1; --Success
					SET @Message = 'Check Out has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.' ;

					DECLARE @Folio varchar(50); 
					DECLARE @Guest varchar(200);
					 
					SELECT @Folio = CONCAT(LocationCode, FolioNumber), @Guest = FirstName + ' ' + ISNULL(LastName, '')
					 FROM reservation.Reservation r
					INNER JOIN general.Location l ON r.LocationID = l.LocationID
					INNER JOIN guest.Guest g ON r.GuestID = g.GuestID
					INNER JOIN contact.Details d ON g.ContactID = d.ContactID
					WHERE r.ReservationID = @ReservationID

					DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
					DECLARE @Title varchar(200) = 'Check Out for ReservationID: ' + CAST(@ReservationID as varchar(12)) + '. ' + @Guest + ', And Folio No(' + @Folio + ')' + ' has been completed successfully.'
					DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
					EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc

				COMMIT TRANSACTION

				EXEC [app].[spInsertActivityLog] 23,@LocationID,@NotDesc,@UserID,@Message
			END TRY  
			BEGIN CATCH    
				IF (XACT_STATE() = -1) 
				BEGIN  			
					ROLLBACK TRANSACTION;  

					SET @Message = ERROR_MESSAGE();
					SET @IsSuccess = 0; --Error			
				END;    
    
				IF (XACT_STATE() = 1)  
				BEGIN  			
					COMMIT TRANSACTION;   

					SET @IsSuccess = 1; --Success  
					SET @Message = 'Check Out has been successful for Reservation ID: <b>#' + CAST(@ReservationID as varchar(12)) + '</b>.';
				END;  
		
				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
			END CATCH;  			
		END
	ELSE
	BEGIN
		SET @IsSuccess = 0;
		SET @StatusCode = -1;
		SET @Message = 'Someone has change the status of Reservation ID: <b>#' + CAST(@ReservationID as varchar(12))  + '</b>, <br>Please refresh the page.';
	END

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @StatusCode AS [StatusCode]
END