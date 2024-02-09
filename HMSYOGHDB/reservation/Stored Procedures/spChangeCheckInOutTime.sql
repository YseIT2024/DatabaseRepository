CREATE PROCEDURE [reservation].[spChangeCheckInOutTime]
(
	@ReservationID int ,
	@NewCheckinDateTime DateTime=Null,
	@NewCheckOutDateTime DateTime=Null

)
AS
BEGIN 
	Begin Try
       BEGIN TRANSACTION	
		Declare @OldCheckinDateTime DateTime=(Select  RR.ExpectedCheckIn From Reservation.Reservation RR Where RR.ReservationID= @ReservationID);
		Declare @OldCheckOutDateTime DateTime=(Select  RR.ExpectedCheckOut From Reservation.Reservation RR Where RR.ReservationID= @ReservationID);

		If(@NewCheckinDateTime <> @OldCheckinDateTime )
		Begin
		Update RR Set RR.ExpectedCheckIn= @NewCheckinDateTime
		From Reservation.Reservation RR
		Where RR.ReservationID= @ReservationID

		DECLARE @Act VARCHAR(MAX) = 'CheckIn Time updated successfully, For reservationID- ' + Cast(@ReservationID AS Varchar(20))+ ', From '+Cast(@OldCheckinDateTime AS varchar(30))+' to '+Cast(@NewCheckinDateTime AS varchar(30))
		EXEC [app].[spInsertActivityLog]45,1,@Act,75, 'CheckIn Time updated successfully'
		End
		If(@NewCheckOutDateTime <> @OldCheckOutDateTime)
		Begin
		Update RR Set RR.ExpectedCheckOut= @NewCheckOutDateTime
		From Reservation.Reservation RR
		Where RR.ReservationID= @ReservationID

		Set  @Act  = 'CheckOut Time updated successfully, For reservationID- ' + Cast(@ReservationID AS Varchar(20))+ ', From '+Cast(@OldCheckOutDateTime AS varchar(30))+' to '+Cast(@NewCheckOutDateTime AS varchar(30))
		EXEC [app].[spInsertActivityLog]46,1,@Act,75, 'CheckOut Time updated successfully'
		End

	
		SELECT 1 AS IsSuccess, 'Time updated successfully' AS Message;

		COMMIT TRANSACTION	
	End Try

	Begin Catch
	    RollBack TRANSACTION	
		SELECT 0 AS IsSuccess, 'Time updation failed' AS Message;
	End Catch
END;

