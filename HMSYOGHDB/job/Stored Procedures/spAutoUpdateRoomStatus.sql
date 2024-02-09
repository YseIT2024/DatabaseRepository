CREATE Procedure [job].[spAutoUpdateRoomStatus]
as 
begin
	--BEGIN TRY  
	--	BEGIN TRANSACTION
			declare @TempTable1  table (ToDoID INT, RSHistoryID INT,LocationID INT)
			declare @TempTable2 table (ID INT IDENTITY(1,1),RSHistoryID INT)	

			--insert into @TempTable1
			--SELECT  ToDoID,RSHistoryID,LocationID
			--FROM [todo].[ToDo]
			--where CONVERT(date,[DueDateTime]) < CONVERT(date,GETDATE()) AND IsCompleted = 0

	--		insert into @TempTable2
	--		SELECT RSHistoryID
	--		FROM [room].[RoomStatusHistory] 
	--		where RSHistoryID IN(SELECT RSHistoryID FROM @TempTable1) AND ReservationID IS NULL

	--		UPDATE [room].[RoomStatusHistory] SET RoomStatusID= 1 WHERE RSHistoryID IN(SELECT RSHistoryID FROM @TempTable2)

	--		UPDATE [todo].[ToDo] SET IsCompleted = 1,CompletedOn = GETDATE(), Description = 'Auto Updated Status- By System Due date passed' 
	--		WHERE (LocationID IN (Select Distinct LocationID FROM @TempTable1)) AND (RSHistoryID IN (Select Distinct RSHistoryID FROM @TempTable1))

	--		DECLARE @LocationID int;
	--		DECLARE @Location varchar(20);
	--		DECLARE @RoomNo varchar(10);
	--		DECLARE @RSHistoryID int;
	--		DECLARE @Init int = 1;
	--		DECLARE @Count int = (SELECT Count(ID) FROM @TempTable2)
	--		DECLARE @Title varchar(200);
	--		DECLARE @NotDesc varchar(max);

	--		WHILE @Count >= @Init
	--		BEGIN
	--			SET @RSHistoryID = (SELECT RSHistoryID FROM @TempTable2 WHERE ID = @Init)

	--			SELECT @LocationID = t1.LocationID, @Location = l.LocationCode  FROM @TempTable1 t1
	--			INNER JOIN general.Location l ON t1.LocationID = l.LocationID
	--			WHERE t1.RSHistoryID = @RSHistoryID

	--			SET @Title  = 'Auto Update Room Status: ' + @RoomNo + ' status has updated to vacant'
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
end
