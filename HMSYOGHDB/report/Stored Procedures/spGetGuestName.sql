
CREATE PROCEDURE [report].[spGetGuestName] --'2019-01-21','2021-03-08',5
(
	@FromDate Date,
	@ToDate Date,
	@LocationID int,
	@DrawerID int = null,
	@UserID int = null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Balance TABLE(ReservationID INT, Balance DECIMAL(18,4))

	INSERT INTO @Balance(ReservationID, Balance)
	SELECT DISTINCT re.[ReservationID]				
	,(
		bill.TotalAmount
		- (SELECT ISNULL(SUM(gw.Amount),0) FROM guest.GuestWallet gw WHERE gw.ReservationID = re.[ReservationID] AND gw.AccountTypeID NOT IN (7,12,14,20,50,82,83,84,85))
		- CAST(vdcomp.ComplimentaryAmount as decimal(18,2))
		- CAST((SELECT [reservation].[fnGetReservationDiscountAmount](re.ReservationID,re.GuestID)) as decimal(18,2))
	) [Balance]	
	FROM [reservation].[Reservation] re	
	CROSS APPLY (SELECT * FROM [reservation].[fnGetReservationRoomBill](re.ReservationID)) bill 
	CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](re.ReservationID)) vdcomp
	WHERE CAST(re.ActualCheckIn as date) BETWEEN @FromDate AND @ToDate AND re.LocationID = @LocationID 

	SELECT DISTINCT g.GuestID
	,([Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName))) AS [FullName]	
	FROM @Balance b	
	INNER JOIN [reservation].[Reservation] re ON b.ReservationID = re.ReservationID
	INNER JOIN [reservation].[ReservedRoom] rm ON re.ReservationID = rm.ReservationID
	INNER JOIN [currency].[Currency] c ON rm.RateCurrencyID = c.CurrencyID	
	INNER JOIN [guest].[Guest] g ON re.GuestID = g.GuestID
	INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID	
	LEFT JOIN person.Title t ON d.TitleID = t.TitleID
    WHERE b.Balance > 0

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @LocationID , 'Guest Pending Payments', @UserID
END

