CREATE PROCEDURE [BQTReservation].[usp_MediaDetails_IU]
    @UserId int=null,
	@LocationId int=null,
	@BQTMediaDetails AS [BQTReservation].[BQTEventMedia] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';
    BEGIN TRY
        BEGIN TRANSACTION
        --IF EXISTS (SELECT * FROM [BQTReservation].[BQTMediaDetails] WHERE BQTMediaDetailsId = @BQTMediaDetailsId)
        --BEGIN
        --    UPDATE [BQTReservation].[BQTMediaDetails] SET
        --        BookingID = @BookingID,
        --        RequiredMedia = @RequiredMedia,
        --        FromDate = @FromDate,
        --        ToDate = @ToDate,
        --        Remarks = @Remarks,
        --        ModifiedBy = @UserId,
        --        ModifiedDate = GETDATE(),
        --        IsActive = @IsActive
        --    WHERE BQTMediaDetailsId = @BQTMediaDetailsId;

        --    SET @IsSuccess = 1; -- success 
        --    SET @Message = 'BQTMediaDetails Updated Successfully.';
        --END
        --ELSE
        BEGIN
            INSERT INTO [BQTReservation].[BQTMediaDetails] (
                BookingID,
                RequiredMedia,
                FromDate,
                ToDate,
                Remarks,
                CreatedBy,             
                CreatedDate,
				ModifiedDate,
                IsActive
            )
		select BookingID,MeadiaRequired,FromDate,ToDate,Remarks,@UserId,GETDATE(),GETDATE(),1
									from @BQTMediaDetails
           
            

            --SET @BQTMediaDetailsId = SCOPE_IDENTITY();
            SET @IsSuccess = 1; -- success
            SET @Message = 'BQTMediaDetails Inserted successfully.';
        END
		EXEC [app].[spInsertActivityLog] 7, @LocationID, @UserId;
        COMMIT TRANSACTION;
       END TRY
       BEGIN CATCH
        IF (XACT_STATE() = -1) 
        BEGIN
            ROLLBACK TRANSACTION;  
            SET @Message = ERROR_MESSAGE();
            SET @IsSuccess = 0; -- error            
        END;     

        --DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());        
        --EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId;
    END CATCH;  

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END;
