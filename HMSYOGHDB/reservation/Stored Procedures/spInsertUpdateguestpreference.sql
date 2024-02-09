CREATE PROCEDURE [reservation].[spInsertUpdateguestpreference] 
(	
	@ReservationID int,
	@Remarks varchar(Max),
	@UserID int
	
)
as

    DECLARE @IsSuccess bit = 0
	DECLARE @Message varchar(250);

begin
if not exists(select reservationId from reservation.Note where NoteTypeID=5 and ReservationID=@ReservationID)
Begin
insert into reservation.Note (ReservationID,NoteTypeID,Note,UserID,DateTime) values (@ReservationID,5,@Remarks,@UserID,getdate())
                    SET @IsSuccess = 1;
					SET @Message = 'saved successfully.'
end
else
begin
	update reservation.Note set Note=@Remarks,DateTime=GETDATE(),UserID=@UserID
	where NoteTypeID=5 and ReservationID=@ReservationID 

	                SET @IsSuccess = 1;
					SET @Message = 'Updated successfully.'
end
      SELECT @IsSuccess 'IsSuccess', @Message 'Message';
end