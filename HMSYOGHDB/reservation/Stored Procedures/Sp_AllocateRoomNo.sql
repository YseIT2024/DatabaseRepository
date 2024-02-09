CREATE proc [reservation].[Sp_AllocateRoomNo]
(
@ReservationID int,
@UserID int,
@CheckInRooms as [reservation].[CheckInRooms] readonly
)
AS
BEGIN
    DECLARE @IsSuccess BIT = 0;
    DECLARE @Message VARCHAR(MAX) = '';
    DECLARE @CurrencyID INT;

    SET @CurrencyID = (SELECT CurrencyID FROM reservation.Reservation WHERE ReservationID = @ReservationID);

    -- Check if the reservation already has allocated rooms
    IF NOT EXISTS (SELECT 1 FROM [reservation].[ReservedRoom] WHERE ReservationID = @ReservationID)
    BEGIN
        -- If no existing records, then proceed to insert
        INSERT INTO [reservation].[ReservedRoom] ([ReservationID], [RoomID], [StandardCheckInOutTimeID], [IsActive], [RateCurrencyID])
        SELECT @ReservationID, CR.RoomID, 1, 1, @CurrencyID
        FROM @CheckInRooms CR;

        DECLARE @ExpectedCheckIn DATE;
        DECLARE @ExpectedCheckOut DATE;

        SET @ExpectedCheckIn = (SELECT ExpectedCheckIn FROM reservation.Reservation WHERE ReservationID = @ReservationID);
        SET @ExpectedCheckOut = (SELECT ExpectedCheckOut FROM reservation.Reservation WHERE ReservationID = @ReservationID);

        DECLARE @ExpectedCheckInID INT = (CAST(FORMAT(@ExpectedCheckIn, 'yyyyMMdd') AS INT));
        DECLARE @ExpectedCheckOutID INT = (CAST(FORMAT(@ExpectedCheckOut, 'yyyyMMdd') AS INT));

        INSERT INTO [Products].[RoomLogs]
        (
            [RoomID], [FromDateID], [ToDateID], [RoomStatusID], [IsPrimaryStatus],
            [FromDate], [ToDate], [ReservationID], [CreatedBy], [CreateDate]
        )
        SELECT
            RoomID, @ExpectedCheckInID, @ExpectedCheckOutID, 2, 1, @ExpectedCheckIn,
            @ExpectedCheckOut, @ReservationID, @UserID, GETDATE()
        FROM [reservation].[ReservedRoom]
        WHERE ReservationID = @ReservationID AND IsActive = 1;

        SET @IsSuccess = 1; -- Success
        SET @Message = 'Room Allocated successfully.';
    END
    ELSE
    BEGIN
        -- If reservation already has allocated rooms, set IsSuccess to 0 and provide a message
        SET @IsSuccess = 0;
        SET @Message = 'Rooms have already been allocated for this reservation.';
    END

    SELECT @IsSuccess AS IsSuccess, @Message AS Message;
END;