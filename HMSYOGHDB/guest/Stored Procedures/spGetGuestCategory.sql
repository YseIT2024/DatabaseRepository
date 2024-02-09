
CREATE PROCEDURE [guest].[spGetGuestCategory]
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT [GuestCategoryID],[GuestCategoryDescription],[CreatedBy],[CreatedOn]
	FROM [guest].[GuestCategory]
	ORDER BY [GuestCategoryDescription] ASC
END



