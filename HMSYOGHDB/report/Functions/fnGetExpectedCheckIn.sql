
CREATE FUNCTION [report].[fnGetExpectedCheckIn] 
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strExpertCheckInCount varchar(255);

	--set @strExpertCheckInCount = (select * from [Report].[RandomNumberGenerate])
	set @strExpertCheckInCount =(select sum(rooms) from reservation.Reservation where format(ExpectedCheckIn, 'dd/MM/yyyy')=format(@FromDate, 'dd/MM/yyyy') and ReservationStatusID in (1,12,16))


			RETURN @strExpertCheckInCount
END
