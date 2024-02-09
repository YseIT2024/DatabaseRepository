-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [room].[spGetToDoTypes]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 0 [ToDoTypeID],'All' [ToDoType]
	UNION
	SELECT [ToDoTypeID], [ToDoType] FROM [todo].Type
	ORDER BY [ToDoTypeID]
END











