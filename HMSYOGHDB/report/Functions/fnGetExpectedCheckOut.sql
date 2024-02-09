
CREATE FUNCTION [report].[fnGetExpectedCheckOut]
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strExpertCheckOutCount varchar(255);

	set @strExpertCheckOutCount = (select sum(rooms) from reservation.Reservation where FORMAT(ExpectedCheckIn,'dd/MM/yyyy')=FORMAT(@FromDate ,'dd/MM/yyyy')and ReservationStatusID in (4))

			RETURN @strExpertCheckOutCount
END


