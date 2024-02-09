CREATE PROCEDURE [BQTReservation].[usp_InsertUpdateBQTEventMenu_IU]
    @BQTEventMenuId int,
    @BookingID int,
    @APPETIZER varchar(100) = NULL,
    @SOUP varchar(100) = NULL,
    @MAINCOURSE varchar(100) = NULL,
    @DESSERTS varchar(100) = NULL,
    @TEACOFFEE varchar(100) = NULL,
    @OTHERS varchar(100) = NULL,
    @Remarks varchar(255) = 'test',
    @UserId int = NULL,
    @LocationId int = NULL,
    @IsActive bit = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess bit = 0;
    DECLARE @Message varchar(max) = '';

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO [BQTReservation].[BQTEventMenu] (
            BookingID,
            APPETIZER,
            SOUP,
            MAINCOURSE,
            DESSERTS,
            TEACOFFEE,
            OTHERS,
            Remarks,
            CreatedBy,
            CreatedDate,
            IsActive
        )
        VALUES (
            @BookingID,
            @APPETIZER,
            @SOUP,
            @MAINCOURSE,
            @DESSERTS,
            @TEACOFFEE,
            @OTHERS,
            @Remarks,
            @UserId,
            GETDATE(),
            @IsActive
        );

        SET @BQTEventMenuId = SCOPE_IDENTITY();
        SET @IsSuccess = 1; -- success
        SET @Message = 'BQTEventMenu Inserted successfully.';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE() <> 0)
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SET @Message = ERROR_MESSAGE();
        SET @IsSuccess = 0; -- error

        -- Log the error in the activity log
        DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());
        EXEC [app].[spInsertActivityLog] 20, @LocationID, @Act, @UserId;

        -- Re-throw the error
        THROW;
    END CATCH;

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END
