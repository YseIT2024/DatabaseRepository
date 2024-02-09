CREATE PROCEDURE [room].[spAssignRoomService] --1,5,1,1509
(
	@RoomID INT,	
	@RoomStatusID INT,
	@ReservationID INT,	
	@EmployeeID INT,
	@ToDOTypeID INT,
	@FromDateTime DATETIME,
	@ToDateTime DATETIME,
	@PriorityID INT,
	@AssignTo VARCHAR(80),
	@Description VARCHAR(MAX),
	@LocationID INT,
	@UserID INT
)
AS
BEGIN
	-- SET XACT_ABORT ON will cause the transaction to be uncommittable  
	-- when the constraint violation occurs.   
	SET XACT_ABORT ON;  
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(250);
	DECLARE @CurrentDateID INT = (SELECT [app].[fnGetCurrentDate]());
	DECLARE @IsPrimaryStatus BIT = (SELECT IsPrimary FROM room.[RoomStatus] WHERE RoomStatusID=@RoomStatusID);
	DECLARE @RSHistoryID INT;
	DECLARE @FromDateID INT = (SELECT CONVERT(INT,FORMAT(@FromDateTime,'yyyyMMdd')));
	DECLARE @ToDateID INT = (SELECT CONVERT(INT,FORMAT(@ToDateTime,'yyyyMMdd')));

	IF(@ReservationID = 0)
	  SET @ReservationID = NULL;
	
	BEGIN TRY  
		BEGIN TRANSACTION
		IF EXISTS (SELECT RSHistoryID  FROM room.[RoomStatusHistory]  WHERE RoomID=@RoomID AND RoomStatusID=1  AND @CurrentDateID BETWEEN FromDateID AND ToDateID)
			BEGIN
				SET @RSHistoryID=(SELECT MAX(RSHistoryID) FROM room.[RoomStatusHistory] WHERE RoomID=@RoomID AND RoomStatusID=1 AND @CurrentDateID BETWEEN FromDateID AND ToDateID)

				UPDATE room.[RoomStatusHistory] SET RoomStatusID=@RoomStatusID,FromDateID=@FromDateID,ToDateID=@ToDateID,FromDate=@FromDateTime,ToDate=@ToDateTime WHERE RoomID=@RoomID AND RoomStatusID=1  AND @CurrentDateID BETWEEN FromDateID AND ToDateID			
			END
		ELSE
			BEGIN
				INSERT INTO room.[RoomStatusHistory](RoomID,FromDateID,ToDateID,RoomStatusID,IsPrimaryStatus,FromDate,ToDate,ReservationID,UserID)
				VALUES(@RoomID,@FromDateID,@ToDateID,@RoomStatusID,@IsPrimaryStatus,@FromDateTime,@ToDateTime,@ReservationID,@UserID) 

				SET @RSHistoryID=SCOPE_IDENTITY();
			END
					
		INSERT INTO todo.[ToDo](ToDoTypeID,LocationID,DueDateTime,Description,EnteredOn,EnteredBy,PriorityID,AssignTo_EmployeeID,RSHistoryID,AssignTo_Name,IsCompleted)
		VALUES(@ToDOTypeID,@LocationID,@ToDateTime,@Description,GETDATE(),@UserID,@PriorityID,@EmployeeID,@RSHistoryID,@AssignTo,0)		

		SET @IsSuccess = 1;
		SET @Message = '';	
			
		COMMIT TRANSACTION
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			ROLLBACK TRANSACTION;  
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error
		END;    
    
		IF (XACT_STATE() = 1)  
		BEGIN  			
			COMMIT TRANSACTION;   
			SET @IsSuccess = 1; --success  
			SET @Message = '';	
		END;  

		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog] 3,@LocationID,@Act,@UserID	
	END CATCH;

	SELECT @IsSuccess 'IsSuccess', @Message 'Message';
END


