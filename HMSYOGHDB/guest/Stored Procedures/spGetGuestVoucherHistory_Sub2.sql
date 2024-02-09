CREATE PROCEDURE [guest].[spGetGuestVoucherHistory_Sub2]
(	
	@ReservationID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @RoomNo int = 
	(
		SELECT r.RoomNo 
		FROM reservation.ReservedRoom rr
		INNER JOIN room.Room r ON rr.RoomID = r.RoomID 		
		WHERE rr.ReservationID = @ReservationID AND  rr.IsActive = 1
	);
	
	SELECT gf.AccountTypeID
	,@RoomNo RoomNo 
	,[AccountType]
	,[Date]
	,[AccountingDate]
	,c.CurrencySymbol + CAST(CAST([Debit] as decimal(18,2)) as varchar(15)) [Debit]
	,c.CurrencySymbol + CAST(CAST([Credit] as decimal(18,2)) as varchar(15)) [Credit]
	,[Void]	
	,[Remarks]	
	FROM [guest].[vwGuestFolio] gf
	INNER JOIN reservation.ReservedRoom rr ON gf.ReservationID = rr.ReservationID AND rr.IsActive = 1
	INNER JOIN currency.Currency c On rr.RateCurrencyID = c.CurrencyID
	WHERE gf.ReservationID = @ReservationID
	ORDER BY [WalletID]
END
