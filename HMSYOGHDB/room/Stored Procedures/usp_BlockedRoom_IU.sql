

CREATE PROCEDURE [room].[usp_BlockedRoom_IU] --1
	@RoomID INT,
	@FromDate DATETIME,
	@ToDate DATETIME,
	@blockTypeId INT,
	@Status Varchar(50)=null,
	@UserId INT ,
	@BlockedId INT ,
	@Remarks varchar(50),
	@IsActive bit

AS
BEGIN

	DECLARE @CheckInDateId int ;
	DECLARE @CheckOutDateId int ;
	DECLARE @RsHistoryId int;

	DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);
    IF EXISTS(SELECT BlockedId FROM [Products].[BlockedRoom] WHERE BlockedId = @BlockedId AND (FromDate <> @FromDate OR ToDate <> @ToDate))
		BEGIN
			SET @Message = 'Room Already Blocked. Please Select Another One.';
		END
		IF EXISTS
				(SELECT BlockedId FROM [Products].[BlockedRoom] WHERE BlockedId =@BlockedId)
				BEGIN
					UPDATE [Products].[BlockedRoom]
					SET [RoomID]= @RoomID,[FromDate]=@FromDate, [ToDate]=@ToDate, [blockTypeId]=@blockTypeId, [Status]='U',[Remarks]=@Remarks, [IsActive]=@IsActive, [ModifiedBy]=@UserId, [ModifiedOn]=GETDATE()
					WHERE [BlockedId] = @BlockedId;

					Update Products.Room set RoomStatusId=1 where roomid=@RoomID
					
					--select @RsHistoryId=max(rshistoryid) from [Products].[RoomLogs] where [RoomStatusID]=10 and RoomId=@RoomID
					--Update [Products].[RoomLogs] SET [RoomStatusID]=1 where rshistoryid=@RsHistoryId



					SET @IsSuccess = 1; --success 
					SET @Message = 'Room UnBlocked successfully.';
				END
			ELSE
				BEGIN
					INSERT INTO [Products].[BlockedRoom] ([RoomID], [FromDate], [ToDate], [blockTypeId],[Remarks], [Status], [IsActive], [CreatedBy], [CreatedOn])
					VALUES (@RoomID, @FromDate, @ToDate, @blockTypeId,@Remarks, 'B', @IsActive, @UserId, GETDATE())

					SET @BlockedId = SCOPE_IDENTITY();

					Update Products.Room set RoomStatusId=10 where roomid=@RoomID

					SET @CheckInDateId  = (SELECT CAST(FORMAT(@FromDate,'yyyyMMdd') as int));
					SET @CheckOutDateId = (SELECT CAST(FORMAT(@ToDate,'yyyyMMdd') as int));

					INSERT INTO [Products].[RoomLogs]
							([RoomID],[FromDateID],[ToDateID],[RoomStatusID]/*,[IsPrimaryStatus]*/,[FromDate],[ToDate], [ReservationID],[CreatedBy],[CreateDate])	
							VALUES(@RoomID,@CheckInDateId,@CheckOutDateId,10,@FromDate,@ToDate,0,@UserId,getdate())

					SET @IsSuccess = 1; --success
					SET @Message = 'Room Blocked successfully.'

				END

				PRINT 'IsSuccess: ' + CAST(@IsSuccess AS VARCHAR(10));
				PRINT 'Message: ' + @Message;
				SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]			
	
END
