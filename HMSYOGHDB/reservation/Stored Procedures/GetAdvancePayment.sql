
CREATE PROCEDURE [reservation].[GetAdvancePayment]
(	
	@ReservationID int ,
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;	
	

	select isnull(sum(ActualAmount),0) as [Advance] from [account].[Transaction] where ReservationID = @ReservationID and LocationID = @LocationID 
END

