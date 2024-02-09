

CREATE PROC [Housekeeping].[usp_HKGuestTickets_IU]
			@TicketId int=null,
			@TicketTypeId int=null,
			@GuestTypeId int,
			@RoomId int,
			@GuestId int,
			@GuestName varchar(250),
			@ReservationNo int,
			--@RequestFor int,
			@RequestForId int,
			@Subject varchar(50),
			@Description varchar(500),
			@RequestDate datetime,
			@RequestTime datetime,
			@Assignee int =null,
			@Status int,
			@ActionBy int =null,
			@ActionDate datetime =null,
			@ActionTime datetime =null,
			@ActionNarration varchar(500),
			@IsActive Bit, 
			@userId int,   
			@LocationID int
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		--DECLARE @ContactID int;
		--DECLARE @GenderID int;
		--Declare @ImageID int;
		DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		--DECLARE @Title varchar(200);
		--DECLARE @Actvity varchar(max);  
  

		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [Housekeeping].[GuestTickets] WHERE TicketId = @TicketId)
				Begin
					UPDATE [Housekeeping].[GuestTickets]
					SET [TicketTypeId]=@TicketTypeId,					[GuestTypeId]=@GuestTypeId,					[RoomId]=@RoomId, 
					[GuestId]=@GuestId,									[GuestName]=@GuestName,						[ReservationNo]=@ReservationNo,
				   [RequestFor]=@RequestForId,							[Subject]=@Subject,							[Description]=@Description,
				   [RequestDate]=@RequestDate,							[RequestTime]=@RequestTime,					[Assignee]=@Assignee,
				   [Status]=@Status,									[ActionBy]=@ActionBy,						[ActionDate]=@ActionDate,
				   [ActionTime]=@ActionTime,							[ActionNarration]=@ActionNarration,			[ModifiedBy]=@userId,
				   [ModifiedOn]=getdate(),								[IsActive]=@IsActive ,						LocationID=@LocationID
				   WHERE TicketId=@TicketId

				SET @IsSuccess = 1; --success 
				SET @Message = 'Updated successfully.';
				end
			ELSE
			BEGIN
				
				INSERT INTO [Housekeeping].[GuestTickets]
				   ([TicketTypeId],[GuestTypeId],[RoomId],[GuestId],[GuestName]
				   ,[ReservationNo],[RequestFor],[Subject],[Description],[RequestDate]
				   ,[RequestTime],[Assignee],[Status],[ActionBy],[ActionDate]
				   ,[ActionTime],[ActionNarration],[CreatedBy],[CreatedOn],[IsActive] ,LocationId)
				VALUES
					(@TicketTypeId,@GuestTypeId,@RoomId,@GuestId,@GuestName,
					@ReservationNo ,@RequestForId ,@Subject ,@Description ,@RequestDate ,
					@RequestTime ,@Assignee ,@Status ,@ActionBy ,@ActionDate ,			
					@ActionTime ,@ActionNarration ,@userId ,getdate(),	@IsActive ,@LocationID )

				SET @TicketId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Created successfully.'

             END
			
			EXEC [app].[spInsertActivityLog] 7,@LocationID,@userId
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
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@userId	
	END CATCH;  
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END	
