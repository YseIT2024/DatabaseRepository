
CREATE PROCEDURE [guest].[GetGuestCompanybyReservationtype] --5
(
	@ReservationTypeID int
)
AS
BEGIN
	IF(@ReservationTypeID=10)-- Complementary
	BEGIN
		select [CompanyID] , [CompanyName] FROM  [guest].[GuestCompany] With (NOLOCK) WHERE IsActive = 1
	END
	ELSE
	BEGIN
		select [CompanyID] , [CompanyName] FROM  [guest].[GuestCompany] With (NOLOCK) WHERE IsActive = 1 and [ReservationTypeId] = @ReservationTypeID  
    END
END