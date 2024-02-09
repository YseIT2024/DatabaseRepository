CREATE PROC [Housekeeping].[usp_HKLostItemEnquiry_IU]
	@EnquiryId int null,
	@Enquirytype nchar(2),
    @GuestType nvarchar(30),
    @GuestID int,	
    @ItemType nvarchar(30),
    @ItemDescription nvarchar(250),
    @LostDate datetime,
    @LostLocation nvarchar(100),
    @Status int,
	@IsActive Bit,
	@FoundBy varchar(100),
	@StoredBy varchar(100),
	@referenceNo int,
    @userId int,   
	@LocationID int,
	@ReservationId int=null
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
				(SELECT * FROM [Housekeeping].[LostItemEnquiry] WHERE EnquiryId = @EnquiryId)
				Begin
				UPDATE [Housekeeping].[LostItemEnquiry]
				   SET [EnquiryType]=@Enquirytype,
				      [GuestType] = @GuestType, 
					  [GuestID] = @GuestID, 
					  [ItemType] = @ItemType, 
					  [ItemDescription] = @ItemDescription, 
					  [LostDate] = @LostDate, 
					  [LostLocation] = @LostLocation, 
					  [Status] = @Status, 					 
					  [ModifiedBy] = @userId, 
					  [ModifiedOn] = GETDATE(), 
					  [IsActive] = @IsActive,
					  [FoundBy]=@FoundBy,
					  [StoredBy]=@StoredBy,
					  [ReferenceNo]=@referenceNo,
					  [ReservationId]=@ReservationId
				 WHERE [EnquiryId] = @EnquiryId
				SET @IsSuccess = 1; --success 
				SET @Message = 'Updated successfully.';
				end
			ELSE
				Begin
				INSERT INTO [Housekeeping].[LostItemEnquiry]([EnquiryType],				   
				[GuestType],[GuestID],[ItemType],[ItemDescription]
				   ,[LostDate],[LostLocation],[Status],[CreatedBy]
				   ,[CreatedOn],[IsActive],[FoundBy],[StoredBy],[ReferenceNo],[ReservationId])
			 VALUES
				   (@Enquirytype,@GuestType,@GuestID,@ItemType,@ItemDescription,
				   @LostDate,@LostLocation,@Status,@userId, 
				   getdate(),@IsActive,@FoundBy,@StoredBy,@referenceNo,@ReservationId)

				SET @EnquiryId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Created successfully.'
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
