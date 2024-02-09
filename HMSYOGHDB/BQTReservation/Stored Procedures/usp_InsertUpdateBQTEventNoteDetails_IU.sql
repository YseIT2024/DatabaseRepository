CREATE PROCEDURE [BQTReservation].[usp_InsertUpdateBQTEventNoteDetails_IU]
    @BQTEventNoteDetailsId int=null,
    @BookingID int,
    @NotesReservation varchar(100) = NULL,
    @NotesBQTOperation varchar(100) = NULL,
    @NotesFNBOperation varchar(100) = NULL,
    @NotesKitchen varchar(100) = NULL,
    @NotesFO varchar(100) = NULL,
    @NotesHK varchar(100) = NULL,
    @NotesIT varchar(100) = NULL,
    @NotesEng varchar(100) = NULL,
    @NotesSales varchar(100) = NULL,
    @NotesOther varchar(100) = NULL,
    @UserId int=null,
	@LocationId int=null,
    @IsActive bit=1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';

    BEGIN TRY
        BEGIN TRANSACTION

        --IF EXISTS (SELECT * FROM [BQTReservation].[BQTEventNoteDetails] WHERE BQTEventNoteDetailsId = @BQTEventNoteDetailsId)
        --BEGIN
        --    UPDATE [dbo].[BQTEventNoteDetails] SET
        --        BookingID = @BookingID,
        --        NotesReservation = @NotesReservation,
        --        NotesBQTOperation = @NotesBQTOperation,
        --        NotesFNBOperation = @NotesFNBOperation,
        --        NotesKitchen = @NotesKitchen,
        --        NotesFO = @NotesFO,
        --        NotesHK = @NotesHK,
        --        NotesIT = @NotesIT,
        --        NotesEng = @NotesEng,
        --        NotesSales = @NotesSales,
        --        NotesOther = @NotesOther,
        --        ModifiedBy = @UserID,
        --        ModifiedDate = GETDATE(),
        --        IsActive = @IsActive
        --    WHERE BQTEventNoteDetailsId = @BQTEventNoteDetailsId;

        --    SET @IsSuccess = 1; -- success 
        --    SET @Message = 'BQTEventNoteDetails Updated Successfully.';
        --END
        --ELSE
        BEGIN
            INSERT INTO [BQTReservation].[BQTEventNoteDetails] (
                BookingID,
                NotesReservation,
                NotesBQTOperation,
                NotesFNBOperation,
                NotesKitchen,
                NotesFO,
                NotesHK,
                NotesIT,
                NotesEng,
                NotesSales,
                NotesOther,
                CreatedBy,         
                CreatedDate,
                IsActive
            )
            VALUES (
                @BookingID,
                @NotesReservation,
                @NotesBQTOperation,
                @NotesFNBOperation,
                @NotesKitchen,
                @NotesFO,
                @NotesHK,
                @NotesIT,
                @NotesEng,
                @NotesSales,
                @NotesOther,
                @UserID,
                GETDATE(),
                1
            );

            --SET @BQTEventNoteDetailsId = SCOPE_IDENTITY();
            SET @IsSuccess = 1; -- success
            SET @Message = 'BQTEventNoteDetails Inserted successfully.';
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

        DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());        
        EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId;
    END CATCH;  

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END;
