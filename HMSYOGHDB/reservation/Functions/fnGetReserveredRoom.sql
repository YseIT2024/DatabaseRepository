CREATE FUNCTION [reservation].[fnGetReserveredRoom] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strRoom varchar(255);

	--SELECT @strRoom = COALESCE(@strRoom + ',', '') + PR.RoomNo
	--FROM [reservation].[ReservedRoom] RRR
	--INNER JOIN [Products].[Room] PR ON RRR.RoomID = PR.RoomID
	--WHERE RRR.reservationid = @ReservationId AND RRR.IsActive = 1;

	--SELECT @strRoom = COALESCE(@strRoom + ',', '') + PR.RoomNo
	--FROM  [Products].[Room] PR where PR.RoomID in (select distinct RoomID from [reservation].[ReservedRoom] RRR 
	--WHERE RRR.reservationid = @ReservationId AND RRR.IsActive = 1);

	    -- Check if @ReservationId is NULL, and handle accordingly
    IF @ReservationId IS NOT NULL
    BEGIN
        SELECT @strRoom = COALESCE(@strRoom + ', ', '') + CONVERT(varchar(10), PR.RoomNo)
        FROM [reservation].[ReservedRoom] RRR
        INNER JOIN [Products].[Room] PR ON RRR.RoomID = PR.RoomID
        WHERE RRR.reservationid = @ReservationId AND RRR.IsActive = 1;
    END
    ELSE
    BEGIN
        SET @strRoom = 'No Reservation Id Provided';
    END

	RETURN @strRoom;
END