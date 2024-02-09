CREATE proc [guest].[usp_GetGuestLuggage]
(
@FromDate datetime,
@ToDate datetime
)
as
begin 
select * from guest.GuestLuggage
where [CreatedOn] between @FromDate and @ToDate
select * from guest.GuestLuggage
end
