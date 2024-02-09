

 
CREATE FUNCTION [room].[CheckIfRoomAvailable]
(	
	@ExpectedCheckIn datetime,
	@ExpectedCheckOut datetime,	
	@dtReservationDetails as [reservation].[ReservationDetails] readonly
)
RETURNS  varchar(500) 
AS		
BEGIN
	
	DECLARE @ItemID INT,@OutPutMSG varchar(500),@ItemName varchar(255)
	DECLARE BCURSOR CURSOR FOR
	SELECT DISTINCT ItemID FROM @dtReservationDetails ORDER BY ItemID;
	OPEN BCURSOR
	FETCH NEXT FROM BCURSOR INTO @ItemID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		 BEGIN  			
			if exists(select RD.ItemID from @dtReservationDetails DT
			inner join reservation.ReservationDetails RD on RD.ItemID=DT.ItemID
			inner join reservation.Reservation RR on RR.ReservationID=RD.ReservationID
			inner join Products.Item itm on RD.ItemID = itm.ItemID
			where DT.ItemID=@ItemID and RR.ReservationStatusID in(1,3) and (@ExpectedCheckIn BETWEEN ExpectedCheckIn AND ExpectedCheckOut OR @ExpectedCheckOut BETWEEN ExpectedCheckIn AND ExpectedCheckOut)
			)
			BEGIN
				select @ItemName = itm.ItemName from @dtReservationDetails DT
				inner join reservation.ReservationDetails RD on RD.ItemID=DT.ItemID
				inner join reservation.Reservation RR on RR.ReservationID=RD.ReservationID
				inner join Products.Item itm on RD.ItemID = itm.ItemID
				where DT.ItemID=@ItemID and RR.ReservationStatusID in(1,3) and (@ExpectedCheckIn BETWEEN ExpectedCheckIn AND ExpectedCheckOut OR @ExpectedCheckOut BETWEEN ExpectedCheckIn AND ExpectedCheckOut)
				
				set @OutPutMSG = @OutPutMSG+ @ItemName + ','
			END		   
		 END   
		FETCH NEXT FROM BCURSOR INTO @ItemID;
	END
	CLOSE BCURSOR;
	DEALLOCATE BCURSOR;
	SET @OutPutMSG = 'Insufficient vacant room for reservation for :' + substring(@OutPutMSG, 1, (len(@OutPutMSG) - 1))

	RETURN  @OutPutMSG
END









