
CREATE PROCEDURE [guest].[spCreateGuestVoucher] --1049,2000,1
(
	@ReservationID int,
	@Amount decimal(18,6),
	@DrawerID int,
	@UserID int,
	@ValidFrom datetime = NULL,
	@ValidTo datetime = NULL
)
AS
BEGIN	
	DECLARE @LocationID int;
	DECLARE @VoucherNumber varchar(100);
	
	DECLARE @VoucherID int;
	DECLARE @GuestID int;	
	DECLARE @CurrencyID int;	
	DECLARE @ExchangeRate decimal(18,6);	

	BEGIN TRY
		SELECT @LocationID = r.LocationID
		,@GuestID = r.GuestID
		,@CurrencyID = rr.RateCurrencyID
		FROM reservation.Reservation r
		INNER JOIN reservation.ReservedRoom rr ON r.ReservationID = rr.ReservationID AND rr.IsActive = 1
		WHERE r.ReservationID = @ReservationID

		SELECT @ExchangeRate = r.ExchangeRate
		FROM [currency].[vwCurrentExchangeRate] r
		WHERE r.CurrencyID = @CurrencyID AND r.DrawerID = @DrawerID
		
		IF(@ValidFrom IS NULL)
			SET @ValidFrom = GETDATE();

		IF(@ValidTo IS NULL)
			SET @ValidTo = DATEADD(DAY,180,@ValidFrom);

		SET @VoucherNumber = CAST(@LocationID as varchar(2)) + FORMAT(@ValidFrom,'yyyyMMddHHmmss');		

		INSERT INTO [guest].[Voucher]
		([VoucherNumber],[ReservationID],[GuestID],[Amount],[CurrencyID],[ExchangeRate],[ValidFrom],[ValidTo])
		VALUES(@VoucherNumber,@ReservationID,@GuestID,@Amount,@CurrencyID,@ExchangeRate,@ValidFrom,@ValidTo)
		
		SET @VoucherID = SCOPE_IDENTITY(); --Success
		
		DECLARE @Guest varchar(200) = (SELECT FirstName + ' ' + ISNULL(LastName,'') FROM guest.Guest g
		INNER JOIN contact.Details d ON g.ContactID = d.ContactID
		WHERE g.GuestID = @GuestID)
		DECLARE @Drawer varchar(20) = (SELECT Drawer FROM app.Drawer WHERE DrawerID = @DrawerID);
		DECLARE @Title varchar(200) = 'Guest Voucher: ' + 'A voucher number ' + '''' + @VoucherNumber + '''' + ' has generated for guest ' + @Guest 
		DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. Transaction by User ID:' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc		
	END TRY  
	BEGIN CATCH    
		SET @VoucherID = 0;
		SET @VoucherNumber = '';
	END CATCH;

	SELECT @VoucherID [VoucherID], @VoucherNumber [VoucherNumber];
END

