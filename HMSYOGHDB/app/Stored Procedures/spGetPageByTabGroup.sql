
CREATE Proc [app].[spGetPageByTabGroup]
(
	@TabGroupID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 0 ObjectID, 'Select a Page' DisplayText

	UNION ALL

	SELECT ObjectID, DisplayText
	FROM  app.[Object]
	WHERE TabGroupID = @TabGroupID AND IsAutoObject = 1
END


