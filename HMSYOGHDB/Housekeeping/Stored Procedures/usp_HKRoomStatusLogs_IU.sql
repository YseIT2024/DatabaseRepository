CREATE PROC [Housekeeping].[usp_HKRoomStatusLogs_IU]
    @HKStatusLogID int,
    @RoomID int,
    @RoomStatusID int,
    @AttendedBy int,
    @Remarks nvarchar(200),
    @CreatedBy int,
   -- @CreateDate DATETIME,
	@LocationID int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		DECLARE @ContactID int;
		DECLARE @GenderID int;
		--Declare @ImageID int;
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		DECLARE @Title varchar(200);
		DECLARE @Actvity varchar(max); 
		DECLARE @CurrentDateId int;
	    DECLARE @NextDayDateId int;	
	
			SET @CurrentDateId = CAST(FORMAT(GETDATE(),'yyyyMMdd') as int);
			SET @NextDayDateId = CAST(FORMAT(DATEADD(DAY,1,GETDATE()),'yyyyMMdd') as int);
  

		BEGIN TRY	
		BEGIN TRANSACTION
			--IF EXISTS
			--	(SELECT * FROM Housekeeping.HKRoomStatusLogs WHERE HKStatusLogID = @HKStatusLogID)
			--	UPDATE Housekeeping.HKRoomStatusLogs
			--	SET    RoomID = @RoomID, RoomStatusID = @RoomStatusID, AttendedBy = @AttendedBy, 
			--	Remarks = @Remarks, CreatedBy = @CreatedBy, CreateDate = GETDATE()
			--	WHERE  HKStatusLogID = @HKStatusLogID
			
			--ELSE
				INSERT INTO Housekeeping.HKRoomStatusLogs ( RoomID, RoomStatusID, AttendedBy, Remarks, 
												CreatedBy, CreateDate)
					SELECT  @RoomID, @RoomStatusID, @AttendedBy, @Remarks, @CreatedBy,GETDATE()

					UPDATE Products.Room SET RoomStatusID = @RoomStatusID  where RoomID = @RoomID

					--UPDATE [Products].[RoomLogs]
					--SET RoomStatusID = @RoomStatusID 
					--,IsPrimaryStatus = 0
					--,ToDate = @ActualCheckOut
					--,ToDateID = @CurrentDateId
					--WHERE RSHistoryID = @RSHistoryID

					INSERT INTO [Products].[RoomLogs]
					([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[CreatedBy],[CreateDate])	
					values(@RoomID,@CurrentDateId,@NextDayDateId,@RoomStatusID,1,GETDATE(),GETDATE(),@CreatedBy,GETDATE())

			SET @IsSuccess = 1; --success
			SET @Message = 'Status log has been saved successfully.'

			SET @Title  = 'Status: ' + STR(@RoomStatusID) + ' has added'
			SET @Actvity = @Title + ' at ' + @Location +  '. By User ID:' + CAST(@CreatedBy as varchar(10)) /*+ ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') */;
			EXEC [app].[spInsertActivityLog] 7,@LocationID, @Actvity,@CreatedBy
	COMMIT TRANSACTION	
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END; 		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@CreatedBy	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	

