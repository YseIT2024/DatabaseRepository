
CREATE PROCEDURE [guest].[spGetGuestWalletBalanceEuro]
(
	@GuestID int
)
AS
BEGIN
	SET NOCOUNT ON;	

	SELECT ISNULL(CAST(SUM(Amount) as decimal(18,2)),0) [TotalBalance]
	FROM [guest].[GuestWallet]
	WHERE GuestID = @GuestID
END









