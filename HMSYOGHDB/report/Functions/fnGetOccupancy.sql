
create FUNCTION [report].[fnGetOccupancy] 
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strOccupancyCount varchar(255);

	set @strOccupancyCount = (select sum(rooms) from reservation.Reservation where Format(ExpectedCheckIn, 'dd/MM/yyyy')=Format(@FromDate, 'dd/MM/yyyy') and ReservationStatusID in (3))

			RETURN @strOccupancyCount
END