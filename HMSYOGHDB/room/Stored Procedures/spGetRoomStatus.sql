-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [room].[spGetRoomStatus]-- 1,14,1
(
	@LocationID INT,
	@RoomID INT,
	@DrawerID INT = 1
)
AS
BEGIN
	
	DECLARE @Status INT	
	DECLARE @ReservationID INT
	DECLARE @Name VARCHAR(200)
	DECLARE @AccountingDate DATE;

	SET @AccountingDate = (SELECT AccountingDate FROM account.AccountingDates WHERE DrawerID = @DrawerId AND IsActive = 1)


	IF  EXISTS (SELECT rsh.RoomID FROM [room].[RoomStatusHistory] rsh
	INNER JOIN [todo].[ToDo] td ON rsh.RSHistoryID = td.RSHistoryID AND rsh.RoomID = @RoomID AND LocationID = @LocationID
	WHERE td.IsCompleted = 0)
	BEGIN
		SET	@Status = 2; --need to close House Keeping
		SELECT @Status as Status, '' Name, 0 ReservationID
		RETURN;
	END
	
	SET @ReservationID = (SELECT top 1 rn.ReservationID FROM [reservation].[Reservation] rn
	INNER JOIN [reservation].[ReservedRoom] rm ON rn.ReservationID = rm.ReservationID AND rn.LocationID = @LocationID AND rn.ReservationStatusID = 3 AND RoomID = @RoomID
	WHERE --@AccountingDate >= CONVERT(DATE,ExpectedCheckOut) AND 
	rn.ActualCheckOut IS NULL AND rm.IsActive = 1) 

	IF @ReservationID IS NOT NULL   
	BEGIN	   
		SET	@Status = 1; --need to check out		
		SET @Name = (SELECT [Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) FROM reservation.vwReservationDetails WHERE ReservationID = @ReservationID)
		SELECT @Status as Status,@Name as Name,  @ReservationID as ReservationID 
		RETURN;
	END
	
	SET @Status = 3; ---need to check in

	SELECT @Status as Status, '' Name, 0 as ReservationID 

   
END

