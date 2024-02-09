

CREATE FUNCTION [reservation].[fnGetFolioNumber]
(
	@ReservationID INT
)
RETURNS VARCHAR(15)
AS
BEGIN
	DECLARE @FolioNumber varchar(15);
		
	SELECT @FolioNumber = (l.LocationCode + CAST(r.FolioNumber as varchar(20))) 
	FROM [reservation].[Reservation] r	
	INNER JOIN general.[Location] l ON r.LocationID = l.LocationID 
	WHERE ReservationID = @ReservationID

	RETURN @FolioNumber;
END


