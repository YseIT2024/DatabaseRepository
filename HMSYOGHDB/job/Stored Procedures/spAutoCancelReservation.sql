CREATE Procedure [job].[spAutoCancelReservation]
AS
BEGIN	
	--BEGIN TRY  
	--	BEGIN TRANSACTION
			declare @TempTable  table (ID INT IDENTITY(1,1), ReservationId int,StatusId int , Remarks varchar(350), UserId int, InsertedDate datetime)
	
	--		INSERT into @TempTable
	--		SELECT [ReservationID], 2, 'Auto Cancel reservation due to date passed for check-in', 1,  getdate()
	--		FROM [reservation].[Reservation]
	--		where [ActualCheckIn] is null and convert(date,[ExpectedCheckIn]) < convert(date,GETDATE()) and [ReservationStatusID] = 1
			
	--		INSERT INTO reservation.ReservationStatusLog
	--		(ReservationID, ReservationStatusID, Remarks, UserID, [DateTime])
	--		select ReservationId, StatusId, Remarks, UserId, InsertedDate from @TempTable
	
	--		UPDATE reservation.Reservation
	--		SET ReservationStatusID = 2
	--		where reservation.Reservation.ReservationID IN
	--		(
	--			SELECT [ReservationID]
	--			FROM [reservation].[Reservation] 
	--			where [ActualCheckIn] is null and convert(date,[ExpectedCheckIn]) < convert(date,GETDATE())
	--		)

	--		UPDATE [room].[RoomStatusHistory]
	--		SET [RoomStatusID] = 9 --Invalid
	--		,[IsPrimaryStatus] = 0
	--		WHERE ReservationID IN
	--		(
	--			SELECT [ReservationID]
	--			FROM [reservation].[Reservation] 
	--			where [ActualCheckIn] is null and convert(date,[ExpectedCheckIn]) < convert(date,GETDATE())
	--		)

	--		DECLARE @Init INT = 1;
	--		DECLARE @Count INT = (SELECT COUNT(ID) FROM @TempTable)
	--		DECLARE @Title varchar(200);
	--		DECLARE @NotDesc varchar(max);
	--		DECLARE @Location varchar(10);
	--		DECLARE @Folio varchar(50);
	--		DECLARE @ReservationID int;
	--		DECLARE @LocationID int;

	--		WHILE @Count >= @Init
	--		BEGIN	
	--			SET @ReservationID = (SELECT ReservationId FROM @TempTable WHERE ID = @Init)
	--			SELECT @LocationID = r.LocationID,  @Location = LocationCode, @Folio = CONCAT(LocationCode, FolioNumber) FROM reservation.Reservation r
	--			INNER JOIN general.Location l ON r.LocationID = l.LocationID
	--			WHERE r.ReservationID = @ReservationID
							
	--			SET @Title  = 'Auto Cancel Reservation: ' + @Folio + ' folio number reservation has cancelled'
	--			SET @NotDesc = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by System' ;
	--			EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc

	--			SET @Init = @Init + 1
	--		END

	--	COMMIT TRANSACTION;
	--END TRY  
	--BEGIN CATCH  
	--	BEGIN  			
	--		ROLLBACK TRANSACTION;
	--	END  
	--END CATCH;
END 
