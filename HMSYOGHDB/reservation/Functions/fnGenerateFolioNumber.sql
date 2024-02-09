
CREATE FUNCTION [reservation].[fnGenerateFolioNumber]
(
	@LocationID INT
)
RETURNS INT
AS
BEGIN
	DECLARE @FolioNumber INT;
	DECLARE @InitFolioNumber INT = 10001;
	
	SELECT @FolioNumber = MAX(r.FolioNumber)
	FROM reservation.Reservation r
	WHERE r.LocationID = @LocationID AND r.FolioNumber IS NOT NULL

	IF(@FolioNumber = 0 OR @FolioNumber IS NULL)
		BEGIN
			SET @FolioNumber = @InitFolioNumber;
		END
	ELSE
		BEGIN
			SET @FolioNumber += 1;
		END

	RETURN @FolioNumber;
END

