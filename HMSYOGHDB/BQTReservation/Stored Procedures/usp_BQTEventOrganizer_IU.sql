CREATE PROCEDURE [BQTReservation].[usp_BQTEventOrganizer_IU]
    @OrgnizerId INT = NULL,
    @OrganizerName VARCHAR(100) = NULL,
    @Address VARCHAR(100) = NULL,
    @Telephone VARCHAR(15) = NULL,
    @Fax INT = NULL,
    @Email VARCHAR(100) = NULL,
    @MobileNumber VARCHAR(15) = NULL,
    @UserId INT = NULL,
    @LocationId INT = NULL,
    @IsActive BIT = 1,
    @BookingId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsSuccess BIT = 0;
    DECLARE @Message VARCHAR(MAX) = '';

    BEGIN TRY
        BEGIN TRANSACTION

       
            INSERT INTO [BQTReservation].[BQTEventOrganizer] (
                OrganizerName,
                Address,
                Telephone,
                Fax,
                Email,
                MobileNumber,
                CreatedBy,
                CreatedDate,
                IsActive,
                BookingId
            )
            VALUES (
                @OrganizerName,
                @Address,
                @Telephone,
                @Fax,
                @Email,
                @MobileNumber,
                @UserId,
                GETDATE(),
                @IsActive,
                @BookingId
            );

            --SET @OrgnizerId = SCOPE_IDENTITY();
            SET @IsSuccess = 1; -- success
            SET @Message = 'BQTEventOrganizer Inserted successfully.';
        

        EXEC [app].[spInsertActivityLog] 7, @LocationId, @UserId;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE() <> 0)
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SET @Message = ERROR_MESSAGE();
        SET @IsSuccess = 0; -- error

        DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());
        EXEC [app].[spInsertActivityLog] 20, @LocationId, @Act, @UserId;
    END CATCH;

    SELECT @IsSuccess AS [IsSuccess], @Message AS [Message];
END;
