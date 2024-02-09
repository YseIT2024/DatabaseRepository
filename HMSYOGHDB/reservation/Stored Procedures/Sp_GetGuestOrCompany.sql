Create proc [reservation].[Sp_GetGuestOrCompany]
(
@ReservationID int,
@CompanyID int=0
)
as
BEGIN 

select ReservationID , FirstName from [reservation].[ReservationGuestMates] where ReservationID=@ReservationID
union
select CompanyID,CompanyName from guest.GuestCompany where CompanyID=@CompanyID

END