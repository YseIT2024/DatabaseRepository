CREATE PROC [reservation].[usp_ReservationServices_Update_API]
@TransId int,
@Status varchar(6)
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN try


    UPDATE reservation.ReservationServices
    SET    Status = @Status 
    WHERE  TransId = @TransId

    /*
    -- Begin Return row code block

    SELECT ReservationID, ServiceId, ServiceDate, ServiceQty, GuestQty, ServiceTimeId, ServiceType, 
           Status, ServiceRate, UserID, DateTime, IsActive, LocationId, RoomId, LocationName, RoomDescription
    FROM   reservation.ReservationServices
    WHERE  TransId = @TransId

    -- End Return row code block

    */
	
	return 
    end try

begin catch
return -1
end catch
