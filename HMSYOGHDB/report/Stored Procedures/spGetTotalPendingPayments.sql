
CREATE PROCEDURE [report].[spGetTotalPendingPayments] --1,1
(
	@LocationID int,
	@DrawerID int,
	@UserID int = null
)
AS
BEGIN
    DECLARE @HotelName varchar(50) = (SELECT LocationName from [general].[Location] where LocationID = @LocationID);
	DECLARE @HotelCode varchar(20) = (SELECT LocationCode from [general].[Location] where LocationID = @LocationID);
	DECLARE @PrintedOn varchar(20) = Format(GETDATE(),'dd-MMM-yyyy hh:mm tt');	
	DECLARE @Balance TABLE(ReservationID INT, Amount DECIMAL(18,4), Paid DECIMAL(18,4), Balance DECIMAL(18,4));

	INSERT INTO @Balance(ReservationID, Amount, Paid, Balance)
	SELECT DISTINCT re.[ReservationID]	
	,CAST(fn.PayableAmount as decimal(18,2)) 
	,CAST(fn.TotalPayment as decimal(18,2))
	,CAST(fn.Balance as decimal(18,2))
	FROM [reservation].[Reservation] re	
	CROSS APPLY (SELECT * FROM [account].[fnGetReservationPayments](re.ReservationID)) fn 
	WHERE re.LocationID = @LocationID AND re.ReservationStatusID IN (3,4)
	AND fn.Balance  > 0
	

	SELECT (l.LocationCode + CAST(re.FolioNumber as varchar(20))) [FolioNumber]
	,CONCAT(d.FirstName,' ',d.LastName) [GuestName]
	,r.RoomNo [RoomNo]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Amount as decimal(18,2))) [TotalAmount]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Paid as decimal(18,2))) [Paid]
	,c.CurrencySymbol + ' ' + CONVERT(VARCHAR,CAST(b.Balance as decimal(18,2))) [Balance]	
	,@HotelName [HotelName]
	,@HotelCode [HotelCode]
	,@PrintedOn [PrintedOn]
	FROM @Balance b	
	INNER JOIN [reservation].[Reservation] re ON b.ReservationID = re.ReservationID
	INNER JOIN [reservation].[ReservedRoom] rm ON re.ReservationID = rm.ReservationID
	INNER JOIN [currency].[Currency] c ON rm.RateCurrencyID = c.CurrencyID
	INNER JOIN general.[Location] l ON re.LocationID = l.LocationID
	INNER JOIN [guest].[Guest] g ON re.GuestID = g.GuestID
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID	
	INNER JOIN [room].[Room] r ON rm.RoomID = r.RoomID	
    WHERE re.LocationID = @LocationID AND b.Balance > 0	AND re.ReservationStatusID IN (3,4)
	
	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Total Pending Payments', @UserID	
END

