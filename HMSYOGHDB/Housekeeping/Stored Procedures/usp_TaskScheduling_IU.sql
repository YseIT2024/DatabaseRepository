
CREATE PROC [Housekeeping].[usp_TaskScheduling_IU]
    @ChecklistScheduleId int ,
    @ChecklistId int,
	@FromDate datetime,
	@ToDate datetime,
	@ScheduleType Bit,  --AllDay/Anytime
	@FromTime datetime  =null,	
	@ToTime datetime  =null,
	@Repeat Bit,
	@Frequency varchar(50), 
	@Sunday varchar(12) =null,
	@Monday varchar(12)=null ,
	@Tuesday varchar(12)=null ,
	@Wednesday varchar(12)=null ,
	@Thursday varchar(12)=null ,
	@Friday varchar(12)=null,
	@Saturday varchar(12)=null,	
	@StatusId int=null,
	@IsActive Bit=null, 
    @userId int,   
	@LocationID int,
	@MonthlyScheduleDate datetime =null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';
	DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID) 	
	
	DECLARE @DayCount int ;
	DECLARE @ScheduleFromDate datetime;
	DECLARE @ScheduleToDate datetime;
	DECLARE @ScheduleDate datetime;
	DECLARE @DayOfWeek varchar(12);
	
	   
	SET @DayCount=DATEDIFF(DAY, @FromDate,@ToDate)


		BEGIN TRY	
		BEGIN TRANSACTION
			IF EXISTS
				(SELECT * FROM [Housekeeping].[HKChecklistSchedule] WHERE ChecklistScheduleId = @ChecklistScheduleId)
				Begin
					--UPDATE [Housekeeping].[HKChecklistSchedule]
					--SET   FromDate = @FromDate,ToDate=@ToDate,ScheduleType=@ScheduleType,Repeat=@Repeat,Frequency=@Frequency
					--	  ,StatusId=@StatusId,IsActive = @IsActive, ModifiedBy = @userId ,CreatedOn= GETDATE()
					--WHERE  ChecklistId = @ChecklistId
					SET @IsSuccess = 1; --success 
					SET @Message = 'Schedule cannot be modified. Please create a new Schedule.';
				End			
			ELSE
			begin
				Insert Into [Housekeeping].[HKChecklistSchedule] 
					([ChecklistId],[FromDate],[ToDate],[ScheduleType],[Repeat],[Frequency],[StatusId],IsActive,CreatedBy,CreatedOn) 
			        Values (@ChecklistId,@FromDate,@ToDate,@ScheduleType,@Repeat,@Frequency,@StatusId,@IsActive,@userId,GETDATE())							   

			   SET @ChecklistScheduleId = SCOPE_IDENTITY();


			   -----Insert into details------
				SET @ScheduleFromDate =@FromDate;
				SET @ScheduleToDate =@ToDate;
			   
			   while(@ScheduleFromDate <=@ToDate)				
				Begin					
					if lower(@Frequency) = 'daily'
						begin					
						   INSERT INTO [Housekeeping].[HKChecklistScheduleDetails]
										   ([ChecklistScheduleId],[ChecklistId],
										   [ScheduleDate],[ScheduleFromTime],[ScheduleToTime],
										   [StatusId],[IsActive],[CreatedBy],[CreatedOn])
									 VALUES
										   (@ChecklistScheduleId,@ChecklistId, 
										   @ScheduleFromDate,@FromTime,@ToTime, 
										   0,1,@userId,GETDATE())						
						end
					Else if lower(@Frequency) = 'weekly'
						begin
							--set @DayOfWeek= DAYOFWEEK(@ScheduleFromDate);

							set @DayOfWeek= DATENAME(WEEKDAY, @ScheduleFromDate);
							

							if (@DayOfWeek=@Sunday or @DayOfWeek=@Monday or @DayOfWeek=@Tuesday or @DayOfWeek=@Wednesday or @DayOfWeek=@Thursday or @DayOfWeek=@Friday or @DayOfWeek=@Saturday)	
								begin	
									INSERT INTO [Housekeeping].[HKChecklistScheduleDetails]
										   ([ChecklistScheduleId],[ChecklistId],
										   [ScheduleDate],[ScheduleFromTime],[ScheduleToTime],
										   [StatusId],[IsActive],[CreatedBy],[CreatedOn])
									 VALUES
										   (@ChecklistScheduleId,@ChecklistId, 
										   @ScheduleFromDate,@FromTime,@ToTime, 
										   0,1,@userId,GETDATE())
								end
						end
					Else if lower(@Frequency) = 'monthly'
						begin
							if (day(@ScheduleFromDate)=day(@MonthlyScheduleDate))							
							begin
							 INSERT INTO [Housekeeping].[HKChecklistScheduleDetails]
										   ([ChecklistScheduleId],[ChecklistId],
										   [ScheduleDate],[ScheduleFromTime],[ScheduleToTime],
										   [StatusId],[IsActive],[CreatedBy],[CreatedOn])
									 VALUES
										   (@ChecklistScheduleId,@ChecklistId, 
										   @ScheduleFromDate,@FromTime,@ToTime, 
										   0,1,@userId,GETDATE())
							end
						end

			  SET @ScheduleFromDate=DATEADD(DAY, 1, @ScheduleFromDate)
			  End
			   ------End------------
		

			SET @IsSuccess = 1; --success
			SET @Message = 'Task Scheduled Successfully.'
			end
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
