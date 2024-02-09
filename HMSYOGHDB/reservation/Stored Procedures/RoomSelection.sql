
CREATE PROC [reservation].[RoomSelection]
(
	@ReservationId int	
)
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	
			SELECT   PR.RoomID,CONVERT(varchar(10), PR.RoomNo) AS RoomNo
            FROM [reservation].[ReservedRoom] RRR
            INNER JOIN [Products].[Room] PR ON RRR.RoomID = PR.RoomID
            WHERE RRR.reservationid =@ReservationId AND RRR.IsActive = 1;
END	

