CREATE PROC [reservation].[spReservedToRequested] --5144,75
    @ReservationID int,
	@UserID Int
	--@TaxRefNo varchar(150)=Null,
	--@CheckInRooms as [reservation].[CheckInRooms] readonly
AS 
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommi ttable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
	DECLARE @FolioNumber int;
	DECLARE @LocationID int;
	DECLARE @FolioNumbers VARCHAR(100) = '';
	DECLARE @AUTOID INT;
	DECLARE @TaxExemptionDetailsId INT;
	IF((SELECT top 1 ReservationStatusID FROM reservation.Reservation WHERE ReservationID = @ReservationID) = 1) --In House
			Begin

				BEGIN TRY	
	
							SET @LocationID = (Select LocationID from [reservation].[Reservation] where ReservationID = @ReservationID)
							DECLARE @LocationCode VARCHAR(10) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationID);
							SET @FolioNumber = (SELECT [reservation].[fnGenerateFolioNumber](@LocationID));
							--If(@TaxRefNo IS NOT NULL)
				   --          BEGIN
							--	  INSERT INTO reservation.TaxExemptionDetails (TaxRefNo, CreatedDate, UserId, ReservationID)
							--	  VALUES (@TaxRefNo, GETDATE(), @UserID, @ReservationID);
							--	-- Retrieve the identity value of the inserted row
							--	-- SET @TaxExemptionDetailsId = SCOPE_IDENTITY();
					
							--	----------Added By Somnath---------------
							--	SET @Message ='New TAX Certificate created successfully';
							--	Declare  @Acts nVarchar(MAX) = 'New TAX Certificate created successfully for the ReservationID- : '+ Cast(@ReservationID AS Varchar(20))+ ' And Folio No. As- '+  Cast(@FolioNumbers AS Varchar(20)) + ' With tax Reference No As ' +Cast(@TaxRefNo AS Varchar(20))+ ' On Date- ' +  Cast(GETDATE() AS Varchar(20))+' By UserID- '+Cast(@UserID AS Varchar(20));
							--		EXEC [app].[spInsertActivityLog] 40,@LocationID,@Acts,@UserID,@Message
							--	----------Added By Somnath---------------

				   --          END	

							UPDATE [reservation].[Reservation]
								SET ReservationStatusID = 12 --Requested
								, FolioNumber = @FolioNumber
								WHERE  ReservationID = @ReservationID

								 INSERT INTO [reservation].[ReservationStatusLog]
										 ([ReservationID],ReservationStatusID,Remarks,UserID,DateTime,ReservedRoomRateID)
										 VALUES (@ReservationID,1,'ReinstatedFromReservedToRequested',@UserID,GETDATE(),0)
						 
								declare @TotalAmountBeforeTax decimal(18,2)
								declare @TotalAmountAfterTax decimal(18,2)

								select @TotalAmountBeforeTax=TotalAmountBeforeTax, @TotalAmountAfterTax=TotalAmountAfterTax from reservation.Reservation where ReservationID=@ReservationID

					
							
							
										DECLARE @CurrencyID INT;

								SET @CurrencyID = (SELECT CurrencyID FROM reservation.Reservation WHERE ReservationID = @ReservationID);

								-- Check if the reservation already has allocated rooms
								IF EXISTS (SELECT 1 FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID)
								BEGIN
									-- If no existing records, then proceed to insert
									Delete From [reservation].[ReservedRoom] WHERE  ReservationID = @ReservationID
									Delete From [Products].[RoomLogs] WHERE  ReservationID = @ReservationID

									--DECLARE @ExpectedCheckIn DATE;
									--DECLARE @ExpectedCheckOut DATE;

									--SET @ExpectedCheckIn = (SELECT ExpectedCheckIn FROM reservation.Reservation WHERE ReservationID = @ReservationID);
									--SET @ExpectedCheckOut = (SELECT ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID = @ReservationID);

									--DECLARE @ExpectedCheckInID INT = (CAST(FORMAT(@ExpectedCheckIn, 'yyyyMMdd') AS INT));
									--DECLARE @ExpectedCheckOutID INT = (CAST(FORMAT(@ExpectedCheckOut, 'yyyyMMdd') AS INT));

									--INSERT INTO [Products].[RoomLogs]
									--(
									--	[RoomID], [FromDateID], [ToDateID], [RoomStatusID], [IsPrimaryStatus],
									--	[FromDate], [ToDate], [ReservationID], [CreatedBy], [CreateDate]
									--)
									--SELECT
									--	RoomID, @ExpectedCheckInID, @ExpectedCheckOutID, 2, 1, @ExpectedCheckIn,
									--	@ExpectedCheckOut, @ReservationID, @UserID, GETDATE()
									--FROM [reservation].[ReservedRoom]
									--WHERE ReservationID = @ReservationID AND IsActive = 1;
									END
														--UPDATE [Products].[Room] SET [RoomStatusID] = 2 --Reserved
														--WHERE RoomID in(SELECT RoomID FROM @CheckInRooms)
							

								--SET @FolioNumbers = @LocationCode + CONVERT(VARCHAR,@FolioNumber) 
								---
								SET @FolioNumbers =@FolioNumber  ---DONE BY MURUGESH S  --
								SET @IsSuccess = 1; --success 
								SET @Message = 'Reservation  successfully Reversed from Reserved to Requested  for : ReservationID- ' + Cast(@ReservationID As varchar(20));	
								SET @Title = 'Reservation approved for : ReservationID- ' + Cast(@ReservationID As varchar(20))+' and the FolioNumbers  is : ' + Cast(@FolioNumbers as varchar(10)) ;	

								----------Added By Somnath---------------
					Set @NotDesc = @Title + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));

					EXEC [app].[spInsertActivityLog] 35,@LocationID,@NotDesc,@UserID,@Title
	            				----------Added By Somnath---------------
				END TRY  
				BEGIN CATCH    
					IF (XACT_STATE() = -1) 
					BEGIN  			
						--ROLLBACK TRANSACTION; 			
						SET @Message = ERROR_MESSAGE();			
						SET @IsSuccess = 0; --error			
					END; 		
		
					---------------------------- Insert into activity log---------------	
					DECLARE @Act VARCHAR(MAX)  = (SELECT app.fngeterrorinfo());		
					EXEC [app].[spInsertActivityLog] 35,@LocationID,@Act,@UserID,@Message	-- Changed By Somnath
				END CATCH;  

			SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @FolioNumbers AS [FolioNumber];
		END

END