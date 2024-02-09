-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [person].[spGetGuestDocument] --1
	-- Add the parameters for the stored procedure here
(
	@LocationID INT = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT distinct g.ContactID, [Title] + [FirstName] + ' ' + ISNULL([LastName],'') AS GuestName
	FROM [guest].[Guest] g
	INNER JOIN [contact].[Details] d on g.ContactID = d.ContactID
	INNER JOIN [person].[Title] t on d.TitleID = t.TitleID
	INNER JOIN (SELECT DISTINCT GuestID, LocationID FROM reservation.Reservation) r ON g.GuestID = r.GuestID
	WHERE r.LocationID = @LocationID
	ORDER BY GuestName	

	SELECT distinct g.ContactID, gd.DocumentID, gd.DocumentUrl, it.IDCardTypeName AS DocumentType,
	gd.DocumentUrl AS Viewer, gd.DocumentID AS [Delete]
	FROM [guest].[Guest] g
	INNER JOIN [contact].[Document] cd ON g.ContactID = cd.ContactID
	INNER JOIN [general].[Document] gd ON cd.DocumentID = gd.DocumentID
	INNER JOIN [person].[IDCardType] it ON gd.IDCardTypeID = it.IDCardTypeID
	INNER JOIN (SELECT DISTINCT GuestID, LocationID FROM reservation.Reservation) r ON g.GuestID = r.GuestID
	Where  gd.IsActive = 1 and r.LocationID = @LocationID

END
