CREATE PROC [reservation].[usp_ReservationServices_Update]
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

    UPDATE reservation.ReservationServices
    SET    ReservationID = @ReservationID, ServiceId = @ServiceId, ServiceDate = @ServiceDate, ServiceQty = @ServiceQty, 
           GuestQty = @GuestQty, ServiceTimeId = @ServiceTimeId, ServiceType = @ServiceType, Status = @Status, 
           ServiceRate = @ServiceRate, UserID = @UserID, DateTime = @DateTime, IsActive = @IsActive, 
           LocationId = @LocationId, RoomId = @RoomId, LocationName = @LocationName, RoomDescription = @RoomDescription
    WHERE  TransId = @TransId

    /*
    -- Begin Return row code block

    SELECT ReservationID, ServiceId, ServiceDate, ServiceQty, GuestQty, ServiceTimeId, ServiceType, 
           Status, ServiceRate, UserID, DateTime, IsActive, LocationId, RoomId, LocationName, RoomDescription
    FROM   reservation.ReservationServices
    WHERE  TransId = @TransId

    -- End Return row code block

    */
    COMMIT
