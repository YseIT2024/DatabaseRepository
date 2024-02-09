CREATE PROC [Housekeeping].[usp_HKLostItemDispose_IU]
	@RecordId int null,
	@EnquiryId int,
	@DisposalStatus int =null,
	@DisposeMode int,
	@DisposeDate datetime,
	@DisposeTo varchar(250),
	@DispatchBy varchar (250),
	@Remarks varchar(250),	
	@UserId int,
	@IsActive bit = null,
	@LocationID INT	      
   
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
				(SELECT * FROM [Housekeeping].[LostItemDispatchDetails] WHERE EnquiryId = @EnquiryId)
				Begin
				UPDATE [Housekeeping].[LostItemDispatchDetails]
				SET 				
				DisposalStatus=@DisposalStatus,				
				DisposeMode=@DisposeMode,
				DisposeDate=@DisposeDate,
				DisposeTo=@DisposeTo,
				DispatchBy=@DispatchBy,
				Remarks=@Remarks,				
				ModifiedBy=@UserId,
				ModifiedOn=getdate()
				where EnquiryId=@EnquiryId


			
				SET @IsSuccess = 1; --success 
				SET @Message = 'Updated successfully.';
				end
			ELSE
				Begin
				
				INSERT INTO [Housekeeping].[LostItemDispatchDetails]
							(EnquiryId,DisposalStatus,DisposeMode
							,DisposeDate,DisposeTo,DispatchBy,Remarks
							,CreatedBy,CreatedOn,IsActive,LocationId)
				VALUES
							(@EnquiryId ,@DisposalStatus ,@DisposeMode ,
							@DisposeDate ,@DisposeTo ,@DispatchBy ,@Remarks ,
							@UserId ,getdate(),1 ,@LocationID )  

				SET @EnquiryId = SCOPE_IDENTITY();
				SET @IsSuccess = 1; --success
				SET @Message = 'Saved successfully.'
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


