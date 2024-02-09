CREATE PROCEDURE [reservation].[spChangeBillTo]
(
	@ReservationID int,
	@ConpanyID int,
	@UserID int 
)
AS
BEGIN
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(100) = '';

	DECLARE @LocationID int;
	DECLARE @Location varchar(20);
	DECLARE @Folio varchar(50);

	SELECT @LocationID = r.LocationID, @Location = LocationCode, @Folio = CONCAT(LocationCode, FolioNumber)  
	FROM reservation.Reservation r
	INNER JOIN general.Location l ON r.LocationID = l.LocationID
	WHERE R.ReservationID = @ReservationID

	IF EXISTS(SELECT ReservationID FROM reservation.Reservation WHERE ReservationID = @ReservationID AND ReservationStatusID IN (1,3))
		BEGIN
			INSERT INTO [reservation].[ReservationStatusLog]
			([ReservationID],[ReservationStatusID],[Remarks],[UserID],[DateTime])
			Values(@ReservationID, 9, 'Updated bill to', @UserID, GETDATE())

			UPDATE reservation.Reservation
			SET CompanyID = @ConpanyID
			WHERE ReservationID = @ReservationID

			SET @IsSuccess = 1;
			SET @Message = 'Bill to has been changed successfully.';

			DECLARE @Title varchar(200) = 'Bill To: ' + @Folio + ' folio number bill to has updated to '
			+ (SELECT CompanyName FROM company.Company WHERE CompanyID = @ConpanyID)
			DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Location + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User ID:' + CAST(@UserID as varchar(10));
			EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc
		END
	ELSE
		BEGIN
			SET @IsSuccess = 0;
			SET @Message = 'Reservation not found or checked out.';
		END

	SELECT @Message [Message], @IsSuccess IsSuccess
END

