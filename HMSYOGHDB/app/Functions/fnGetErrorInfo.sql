
CREATE FUNCTION [app].[fnGetErrorInfo]()
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Message VARCHAR(MAX) = 
	(
		'ErrorNumber -> ' + CAST(ERROR_NUMBER() AS VARCHAR(30)) 
		+ ', ErrorSeverity -> ' + CAST(ERROR_SEVERITY() AS VARCHAR(30)) 
		+ ', ErrorState -> ' + CAST(ERROR_STATE() AS VARCHAR(30)) 
		+ ', ErrorLine -> ' + CAST(ERROR_LINE() AS VARchar(30)) 
		+ ', ErrorProcedure -> ' + CAST(ISNULL(ERROR_PROCEDURE(),'') AS VARCHAR(max)) 
		+ ', ErrorMessage -> ' + CAST(ISNULL(ERROR_MESSAGE(),'') AS VARCHAR(max))
	);

	RETURN ISNULL(@Message,'');
END










