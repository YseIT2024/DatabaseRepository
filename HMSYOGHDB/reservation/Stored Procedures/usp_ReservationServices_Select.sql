CREATE PROC [reservation].[usp_ReservationServices_Select]
    @TransId INT = NULL,
    @ReservationID INT = NULL,
    @ServiceTypeID INT = NULL
   
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
    
    IF (@ReservationID <> NULL)
        BEGIN
           SELECT RR.TransId, RR.ReservationID, RR.ServiceId, RR.ServiceDate, RR.ServiceQty, RR.GuestQty, 
            RR.ServiceTimeId, RR.ServiceType, RR.Status, RR.ServiceRate, RR.UserID, RR.DateTime, 
            RR.IsActive, RR.LocationId, RR.RoomId, RR.LocationName, RR.RoomDescription,
            SI.Name, SI.ServiceTypeID, ST.ServiceName,Isnull(RR.Amount,0) as Amount
            FROM   [HMSYOGH].reservation.ReservationServices RR
            INNER JOIN [HMSYOGH].[service].[Item] SI ON RR.ServiceId = SI.ItemID
            INNER JOIN [HMSYOGH].[service].[Type] ST ON SI.ServiceTypeID = ST.ServiceTypeID
			
        END

    ELSE IF(@TransId <> NULL)
        BEGIN
           SELECT RR.TransId, RR.ReservationID, RR.ServiceId, RR.ServiceDate, RR.ServiceQty, RR.GuestQty, 
            RR.ServiceTimeId, RR.ServiceType, RR.Status, RR.ServiceRate, RR.UserID, RR.DateTime, 
            RR.IsActive, RR.LocationId, RR.RoomId, RR.LocationName, RR.RoomDescription,
            SI.Name, SI.ServiceTypeID, ST.ServiceName,Isnull(RR.Amount,0) as Amount
            FROM   [HMSYOGH].reservation.ReservationServices RR
            INNER JOIN [HMSYOGH].[service].[Item] SI ON RR.ServiceId = SI.ItemID
            INNER JOIN [HMSYOGH].[service].[Type] ST ON SI.ServiceTypeID = ST.ServiceTypeID
			
        END

    ELSE
        BEGIN
          SELECT RR.TransId, RR.ReservationID, RR.ServiceId, RR.ServiceDate, RR.ServiceQty, RR.GuestQty, 
            RR.ServiceTimeId, RR.ServiceType, RR.Status, RR.ServiceRate, RR.UserID, RR.DateTime, 
            RR.IsActive, RR.LocationId, RR.RoomId, RR.LocationName, RR.RoomDescription,
            SI.Name, SI.ServiceTypeID, ST.ServiceName,Isnull(RR.Amount,0) as Amount
            FROM   [HMSYOGH].reservation.ReservationServices RR
            INNER JOIN [HMSYOGH].[service].[Item] SI ON RR.ServiceId = SI.ItemID
            INNER JOIN [HMSYOGH].[service].[Type] ST ON SI.ServiceTypeID = ST.ServiceTypeID
			
        END			
END