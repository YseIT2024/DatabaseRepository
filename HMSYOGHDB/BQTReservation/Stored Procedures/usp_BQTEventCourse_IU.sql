CREATE PROCEDURE [BQTReservation].[usp_BQTEventCourse_IU]
    --@BQTEventCourseId int,
    @UserId int=null,
    @LocationId int=null,
    @BQTCourseDetails AS [BQTReservation].[BQTEventCourse] READONLY
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';

    BEGIN TRY
        BEGIN TRANSACTION

        --IF EXISTS (SELECT * FROM [BQTReservation].[BQTEventCourse] WHERE BQTEventCourseId = @BQTEventCourseId)
        --BEGIN
        --    UPDATE [BQTReservation].[BQTEventCourse] SET
        --        BookingID = @BookingID,
        --        FromDate = @FromDate,
        --        FromTime = @FromTime,
        --        ToDate = @ToDate,
        --        ToTime = @ToTime,
        --        Course = @Course,
        --        Remarks = @Remarks,
        --        ModifiedBy = @UserId,
        --        ModifiedDate = GETDATE(),
        --        IsActive = @IsActive
        --    WHERE BQTEventCourseId = @BQTEventCourseId;

        --    SET @IsSuccess = 1; -- success 
        --    SET @Message = 'BQTEventCourse Updated Successfully.';
        --END
       
        BEGIN
            INSERT INTO [BQTReservation].[BQTEventCourse] (
                BookingID,
                FromDate,
                ToDate,
                Course,
                Remarks,
                CreatedBy,             
                CreatedDate,
				--ModifiedDate,
                IsActive
            )
           select BookingID,FromDate,ToDate,Course,Remaraks,@UserId,GETDATE(),1
									from @BQTCourseDetails

            --SET @BQTEventCourseId = SCOPE_IDENTITY();
            SET @IsSuccess = 1; -- success
            SET @Message = 'BQTEventCourse Inserted successfully.';
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
END
