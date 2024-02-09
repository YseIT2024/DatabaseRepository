Create PROCEDURE [BQTReservation].[SpGetEventNames] 
(		
	@EventTypeId INT	        
)
AS
BEGIN
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;

	IF(@EventTypeId <> 0)
		BEGIN
			Select EventId,EventName from [BQTReservation].[Events] where EventTypeId=@EventTypeId
		END	
END
