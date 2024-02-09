CREATE proc [Products].[spUpdateRoomStatus]
@roomstatusid int null,
@attendedboyid int null,
@remarks varchar(300)=null,
@UserId int null,
@Location int null,
@RoomStatus  [Products].[dtProductsRoomStatus] readonly
as
Begin
 SET NOCOUNT ON
 SET XACT_ABORT ON
declare @IsSuccess int=0;
DECLARE @Message varchar(200);
Declare @RoomId int;
DECLARE @Actvity varchar(max);
DECLARE @Title varchar(200);
DECLARE @CurrentDateId int;
DECLARE @NextDayDateId int;	
	
SET @CurrentDateId = CAST(FORMAT(GETDATE(),'yyyyMMdd') as int);
SET @NextDayDateId = CAST(FORMAT(DATEADD(DAY,1,GETDATE()),'yyyyMMdd') as int);

BEGIN TRY	
BEGIN TRANSACTION
  
  INSERT INTO Housekeeping.HKRoomStatusLogs (RoomID, RoomStatusID, AttendedBy, Remarks, CreatedBy, CreateDate) 
  SELECT RoomID, @roomstatusid, @attendedboyid, @Remarks, @UserId, GETDATE() FROM @RoomStatus



 update Products.Room set RoomStatusID=@roomstatusid where RoomID in(select RoomID from @RoomStatus)


 INSERT INTO [Products].[RoomLogs]([RoomID],[FromDateID],[ToDateID],[RoomStatusID],[IsPrimaryStatus],[FromDate],[ToDate],[CreatedBy],[CreateDate])	
 select RoomID,@CurrentDateId,@NextDayDateId,@RoomStatusID,1,GETDATE(),GETDATE(),@UserId,GETDATE() from @RoomStatus
 set @IsSuccess=1
 set @Message='room status updated successfully'; 
SET @Title  = 'Status: ' + STR(@RoomStatusID) + ' has added'
SET @Actvity = @Title + ' at ' + Cast(@Location  as varchar(10)) +  '. By User ID:' + CAST(@UserId as varchar(10))
 EXEC [app].[spInsertActivityLog] 15,@Location, @Actvity,@UserId

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
		EXEC [app].[spInsertActivityLog]15,@Location,@Act,@UserId	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
