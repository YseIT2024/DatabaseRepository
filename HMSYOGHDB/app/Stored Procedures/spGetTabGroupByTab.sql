
CREATE Proc [app].[spGetTabGroupByTab]
(
	@TabID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 0 TabGroupID, 'Select a Tab Group' DisplayText

	UNION ALL

	SELECT TabGroupID, DisplayText
	FROM  app.TabGroup
	WHERE TabID = @TabID 
END


