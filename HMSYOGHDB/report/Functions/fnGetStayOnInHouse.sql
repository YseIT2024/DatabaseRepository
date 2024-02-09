
CREATE FUNCTION [report].[fnGetStayOnInHouse] 
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strStayOnInHouseCount varchar(255);

	set @strStayOnInHouseCount = (select sum(rooms) from reservation.Reservation where format(ExpectedCheckIn, 'dd/MM/yyyy')=format(@FromDate,'dd/MM/yyyy')and ReservationStatusID in (3))

			RETURN @strStayOnInHouseCount
END
