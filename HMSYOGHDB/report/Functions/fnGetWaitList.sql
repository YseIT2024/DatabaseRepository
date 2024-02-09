
CREATE FUNCTION [report].[fnGetWaitList]
(	
	@FromDate datetime,
	@ToDate datetime

)
RETURNS varchar(255)
AS	
BEGIN
	declare @strWaitListCount varchar(255);

	set @strWaitListCount = ((select sum(rooms) from reservation.Reservation where CONVERT(date,ExpectedCheckIn,103)=@FromDate and ReservationStatusID in (12)))

			RETURN @strWaitListCount
END

--select sum(rooms) from reservation.Reservation where CONVERT(date,ExpectedCheckIn,103)='2023/08/01' and ReservationStatusID in (12)
