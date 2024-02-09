
CREATE PROC [Housekeeping].[usp_HKMissingAndDamages_IU]
@TransId int=null,
@TransactionType int,
@TransDate datetime,
@PersonResponsible nvarchar(100)=NULL,
@ItemId int=null,
@ItemDescription nvarchar(100),
@Quantity int,
@LocationType int=null,
@LocationId int=null,
@LocationDescription nvarchar(100),
@ActionTaken int,
@Status int,
@InformedBy nvarchar(50),
@InformedDate datetime,
@InformedTo nvarchar(100),
@ReplacementDate datetime,
@AmountCharged decimal(6,2),
@ReceiptNo int,
@Narration nvarchar(250),
@UserID int
AS 
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) ='';
 
	DECLARE @LocationCode VARCHAR(20) = (SELECT LocationCode FROM general.Location WHERE LocationID = @LocationId);		

	BEGIN TRY		
		BEGIN TRANSACTION							
					IF(@TransId=0 or @TransId=NULL)
						BEGIN		

						INSERT INTO [Housekeeping].[HKMissingAndDamages]
							([TransactionType],[TransDate],[PersonResponsible],[ItemId],[ItemDescription]
							,[Quantity],[LocationType],[LocationId],[LocationDescription]
							,[ActionTaken],[Status]
							,[InformedBy],[InformedDate],[InformedTo],[ReplacementDate],[AmountCharged],[ReceiptNo],
							[Narration],[CreatedOn],[CreatedBy])
						VALUES
							(@TransactionType ,@TransDate,@PersonResponsible,@ItemId ,@ItemDescription,
							@Quantity,@LocationType,@LocationId,@LocationDescription,
							@ActionTaken,@Status ,
							 @InformedBy,@InformedDate,@InformedTo,@ReplacementDate,@AmountCharged,@ReceiptNo,@Narration,getdate(),@UserID)
							SET @IsSuccess = 1; --success
						   SET  @Message = 'Inserted successfully' ;	
						END
					ELSE
						BEGIN
						UPDATE [Housekeeping].[HKMissingAndDamages]
						SET [TransactionType]=@TransactionType,
							[TransDate]=@TransDate,
							[PersonResponsible]=@PersonResponsible,
							[ItemId]=@ItemId,
							[ItemDescription]=@ItemDescription,
							[Quantity]=@Quantity,
							[LocationType]=@LocationType,
							[LocationId]=@LocationId,
							[LocationDescription]=@LocationDescription,
							[ActionTaken]=@ActionTaken,
							[Status]=@Status,
							[InformedBy]=@InformedBy,
							[InformedDate]=@InformedDate,
							[InformedTo]=@InformedTo,
							[ReplacementDate]=@ReplacementDate,
							[AmountCharged]=@AmountCharged,
							[ReceiptNo]=@ReceiptNo,
							[Narration]=@Narration,
							[CreatedOn]=getdate(),
							[CreatedBy]=@UserID
						WHERE TransId=@TransId

						SET @IsSuccess = 1; --success
						SET @Message = 'Updated successfully' ;	
						
						END								
																
					--	DECLARE @NotDesc varchar(max) = @Title + ' at ' + @LocationCode + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
									
					--	EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	
						
					---END	
		COMMIT TRANSACTION					
	END TRY  
	BEGIN CATCH    
		IF (XACT_STATE() = -1) 
		BEGIN  			
			SET @Message = ERROR_MESSAGE();
			SET @IsSuccess = 0; --error			
		END;  
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]20,@LocationID,@Act,@UserID	
	END CATCH;  

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
	
End;
