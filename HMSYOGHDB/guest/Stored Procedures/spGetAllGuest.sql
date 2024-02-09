
CREATE PROCEDURE [guest].[spGetAllGuest]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT DISTINCT GuestID	
	,CountryName [Country]
	,FirstName
	,LastName
	,FullName
	,CAST(0 as bit) [Select]
	FROM guest.vwGuestDetails
	ORDER BY FullName ASC
END

