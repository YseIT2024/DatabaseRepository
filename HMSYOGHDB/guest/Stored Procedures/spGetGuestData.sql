
CREATE PROCEDURE [guest].[spGetGuestData]
(
	@GuestID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
SELECT TOP 1 [GuestID]	
	,t.[TitleID] [TitleID]	
	,[Title]
	,[FirstName]
	,[LastName]
	,[Email]
	,[PhoneNumber]		
	,a.[CountryID]	
	--,d.DOB
	,FORMAT(d.DOB, 'dd-MMM-yyyy') AS DOB
	,d.GenderID
	From [guest].[Guest] g 
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID
	INNER JOIN [contact].[Address] a ON g.ContactID = a.ContactID
	INNER JOIN [general].[Country] c ON a.CountryID = c.CountryID
	INNER JOIN [person].[Title] t ON d.TitleID = t.TitleID
	Where g.GuestID = @GuestID
END
