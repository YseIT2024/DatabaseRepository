CREATE PROC [reservation].[usp_ReservationServices_Insert]
    @TransId int,
    @ReservationID int,
    @ServiceId int,
    @ServiceDate datetime,
    @ServiceQty int,
    @GuestQty int,
    @ServiceTimeId int,
    @ServiceType int,
    @Status varchar(6),
    @ServiceRate decimal,
    @UserID int,
    @DateTime datetime,
    @IsActive int,
    @LocationId int,
    @RoomId int,
    @LocationName nchar(100),
    @RoomDescription nvarchar(100)
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    INSERT INTO reservation.ReservationServices (TransId, ReservationID, ServiceId, ServiceDate, ServiceQty, 
                                                 GuestQty, ServiceTimeId, ServiceType, Status, ServiceRate, 
                                                 UserID, DateTime, IsActive, LocationId, RoomId, LocationName, 
                                                 RoomDescription)
    SELECT @TransId, @ReservationID, @ServiceId, @ServiceDate, @ServiceQty, @GuestQty, @ServiceTimeId, 
           @ServiceType, @Status, @ServiceRate, @UserID, @DateTime, @IsActive, @LocationId, @RoomId, 
           @LocationName, @RoomDescription

    /*
    -- Begin Return row code block

    SELECT TransId, ReservationID, ServiceId, ServiceDate, ServiceQty, GuestQty, ServiceTimeId, ServiceType, 
           Status, ServiceRate, UserID, DateTime, IsActive, LocationId, RoomId, LocationName, RoomDescription
    FROM   reservation.ReservationServices
    WHERE  TransId = @TransId AND ReservationID = @ReservationID AND ServiceId = @ServiceId AND ServiceDate = @ServiceDate AND 
           ServiceQty = @ServiceQty AND GuestQty = @GuestQty AND ServiceTimeId = @ServiceTimeId AND 
           ServiceType = @ServiceType AND Status = @Status AND ServiceRate = @ServiceRate AND UserID = @UserID AND 
           DateTime = @DateTime AND IsActive = @IsActive AND LocationId = @LocationId AND RoomId = @RoomId AND 
           LocationName = @LocationName AND RoomDescription = @RoomDescription

    -- End Return row code block

    */
    COMMIT
