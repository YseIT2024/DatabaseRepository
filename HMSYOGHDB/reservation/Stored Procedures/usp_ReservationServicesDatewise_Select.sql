CREATE PROC [reservation].[usp_ReservationServicesDatewise_Select]-- '2022-01-01', '2024-01-01'
    @FromDate DATETIME,
	@ToDate DATETIME 
	--@ServiceTimeId INT
	
	
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON    

		BEGIN
			--SELECT RR.TransId, RR.ReservationID, RR.ServiceId, RR.ServiceDate, RR.ServiceQty, RR.GuestQty, 
			--RR.ServiceTimeId, RR.ServiceType, RR.Status, RR.ServiceRate, RR.UserID, RR.DateTime, 
			--RR.IsActive, RR.LocationId, RR.RoomId, RR.LocationName, RR.RoomDescription,
			--SI.Name,SI.ServiceTypeID,ST.ServiceName
			--FROM   [HMSYOGH].reservation.ReservationServices RR
			--INNER JOIN [HMSYOGH].[service].[Item] SI ON RR.ServiceId=SI.ItemID
			--INNER JOIN [HMSYOGH].[service].[Type] ST ON SI.ServiceTypeID=ST.ServiceTypeID
			--WHERE RR.ServiceTimeId= @ServiceTimeId AND RR.DateTime BETWEEN @FromDate AND @ToDate
			

			SELECT RS.TransId, RS.ReservationID,			
			 RS.ServiceDate, RS.ServiceQty, RS.GuestQty, 
			RS.ServiceTimeId, 			
			 RS.Status, RS.ServiceRate, RS.IsActive, RS.LocationId, RS.LocationName, RS.RoomDescription,
			RR.[ExpectedCheckIn],RR.[ExpectedCheckOut],RR.[GuestID],
			RR.[Rooms],RR.[Nights],RR.[Adults],RR.[Children],RR.[ReservationStatusID],RR.[LocationID],GG.ContactID,	
			CD.FirstName,CD.LastName, SI.Name AS FoodAddOns			
			FROM   [HMSYOGH].reservation.ReservationServices RS
			INNER JOIN [HMSYOGH].[reservation].[Reservation] RR ON RS.ReservationID=RR.ReservationID
			INNER JOIN [HMSYOGH].[guest].[Guest] GG ON RR.GuestID=GG.GuestID
			INNER JOIN [HMSYOGH].[CONTACT].[DETAILS] CD ON GG.ContactID=CD.ContactID
			INNER JOIN [HMSYOGH].[service].[Item] SI ON RS.ServiceId=SI.ItemID
			INNER JOIN [HMSYOGH].[service].[Type] ST ON SI.ServiceTypeID=ST.ServiceTypeID
			WHERE RS.DateTime BETWEEN @FromDate AND @ToDate
			
		END	

END

