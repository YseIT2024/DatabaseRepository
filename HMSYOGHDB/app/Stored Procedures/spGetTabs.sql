
CREATE Proc [app].[spGetTabs]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 0 TabID, 'Select a Tab' DisplayText

	UNION ALL

	SELECT TabID, DisplayText
	FROM  app.Tab   
END


