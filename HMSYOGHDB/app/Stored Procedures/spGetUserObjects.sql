
CREATE Proc [app].[spGetUserObjects]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ObjectID
	,ObjectName
	,DisplayText
	,ObjectPath 
	,CASE WHEN IsAutoObject = 1 Then 'Auto' ELSE 'Manual' END [Type]
	FROM  [app].[Object]	
END


