-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetDailyComplimentaryReport]
(	
@LocationID int,
@Date date
)
AS
BEGIN
	
	DECLARE @temp TABLE(RoomNo int, GuestName varchar(100), Pax int, CheckIn date,
	CheckOut date, NoOfNights int, RatePerNight Varchar(20), Price varchar(20), AuthBy varchar(50), VerifiedBy varchar(50), ApprovedBy varchar(50), ReceptionistOutgoing varchar(50), ReceptionistIncoming varchar(50), HotelSupervisor varchar(50))

    INSERT INTO @temp (RoomNo, GuestName, Pax, CheckIn,
	CheckOut, NoOfNights, RatePerNight, Price, AuthBy, VerifiedBy, ApprovedBy, ReceptionistOutgoing, ReceptionistIncoming, HotelSupervisor)
	VALUES 
	(101,'jhjkhkj',4,'03-Oct-2019','09-Nov-2019',5,'fgj','fgjddfh','hgfgh','ghfd','hddfhd','dhdf','dh','dhf'),
    (102,'jhjkhkj',4,'03-Oct-2019','09-Nov-2019',5,'fgj','fgjddfh','hgfgh','ghfd','hddfhd','dhdf','dh','dhf'), 
	(103,'jhjkhkj',4,'03-Oct-2019','09-Nov-2019',5,'fgj','fgjddfh','hgfgh','ghfd','hddfhd','dhdf','dh','dhf')
	
	
	SELECT * FROM @temp

END










