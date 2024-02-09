
-- =============================================
-- Author:          <ARABINDA PADHI>
-- Create date: <06/03/2023>
-- Description:     <TO INSERT AND UPDATE THE CUSTOMER DOCUMENT>
-- =============================================

CREATE PROCEDURE [reservation].[spReservationDocumentUpload_IU_Multi]
(	
  @DocumentId int,
  @ReservationID int,
  @CreatedBy int,
  --@CreatedOn datetime,
  @IsActive bit,
  @DocumentTypeId int,
  @DocumentURL nvarchar(250)=null,
  @LocationID	 int,
  @GuestMatesID int,

  -- Added by Vasanth
  @DocumentImage nvarchar(max)=null,
  @DocumentContent nvarchar(max)=null

  )
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 
	
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';		
	DECLARE @OutPutMSG varchar(500);	
	DECLARE @NotDesc varchar(max) = '';
	DECLARE @Title varchar(max) = '';
	DECLARE @ItemID varchar(max) = ''; 

	
	BEGIN TRY	
		BEGIN TRANSACTION
			--IF EXISTS (SELECT DocumentId FROM reservation.ReservationDocumentUpload WHERE DocumentId = @DocumentId)		  
			IF EXISTS (SELECT DocumentId FROM reservation.ReservationMultiDocumentUpload WHERE MultiDocumentID = @DocumentId)		  
			 BEGIN
					UPDATE reservation.ReservationMultiDocumentUpload SET
					  ReservationID = @ReservationID,
					  IsActive = @IsActive,
					  DocumentTypeId = @DocumentTypeId,
					  DocumentURL = @DocumentURL,
					  GuestMatesID = @GuestMatesID,
					  DocumentImage=@DocumentImage,
					  DocumentContent=@DocumentContent
					WHERE MultiDocumentID = @DocumentId

					SET @IsSuccess = 1; --success 
					SET @Message = 'Document update  successfully.';	

					--INSERT INTO reservation.ReservationMultiDocumentUpload (
					--  DocumentId, ReservationID,
					--  CreatedBy,CreatedOn,IsActive,
					--  DocumentTypeId,DocumentURL, GuestMatesID,DocumentImage,DocumentContent)
					--VALUES(
					--  @DocumentId, @ReservationID,
					--  @CreatedBy,GetDate(),@IsActive,
					--  @DocumentTypeId,@DocumentURL, @GuestMatesID,@DocumentImage,@DocumentContent)

					--  SET @IsSuccess = 1; --success 
					--  SET @Message = 'Document added  successfully.';
			END
			ELSE
			BEGIN
					--INSERT INTO reservation.ReservationDocumentUpload (
					--   ReservationID,
					--  CreatedBy,CreatedOn,IsActive,
					--  DocumentTypeId,DocumentURL, GuestMatesID,DocumentImage,DocumentContent)
					--VALUES(
					--  @ReservationID,
					--  @CreatedBy,GetDate(),@IsActive,
					--  @DocumentTypeId,@DocumentURL, @GuestMatesID,@DocumentImage,@DocumentContent)

					--  SET @IsSuccess = 1; --success 
					--  SET @Message = 'Document added  successfully.';	

					  INSERT INTO reservation.ReservationMultiDocumentUpload (
					  DocumentId, ReservationID,
					  CreatedBy,CreatedOn,IsActive,
					  DocumentTypeId,DocumentURL, GuestMatesID,DocumentImage,DocumentContent)
					VALUES(
					  @DocumentId, @ReservationID,
					  @CreatedBy,GetDate(),@IsActive,
					  @DocumentTypeId,@DocumentURL, @GuestMatesID,@DocumentImage,@DocumentContent)

					  SET @IsSuccess = 1; --success 
					  SET @Message = 'Document added  successfully.';
		   	END		 		  
					--INSERT INTO reservation.ReservationMultiDocumentUpload (
					--  DocumentId, ReservationID,
					--  CreatedBy,CreatedOn,IsActive,
					--  DocumentTypeId,DocumentURL, GuestMatesID,DocumentImage,DocumentContent)
					--VALUES(
					--  @DocumentId, @ReservationID,
					--  @CreatedBy,GetDate(),@IsActive,
					--  @DocumentTypeId,@DocumentURL, @GuestMatesID,@DocumentImage,@DocumentContent)

					  --SET @IsSuccess = 1; --success 
					  --SET @Message = 'Document added  successfully.';

		SET @NotDesc = @Message +'for ItemID:'+ STR(@ItemID) + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@CreatedBy as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
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

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @ReservationID as [ReservationID]
END



