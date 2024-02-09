
CREATE PROCEDURE [report].[spGetAccountTransactionSummary] 
(
	@AccountingDate DATE,
	@DrawerIDs as [app].[dtID] readonly
)
AS
BEGIN
	Declare @RowNo int = 1;
	Declare @DrawerID int;

	DECLARE @tbl_Transaction TABLE(TransactionID INT, ReservationID VARCHAR(150), LocationCode VARCHAR(100), Drawer VARCHAR(100), AccountGroupID INT, 
	AccountGroup VARCHAR(250), AccountTypeID INT, AccountType VARCHAR(100), CurrencyCode VARCHAR(100), Amount DECIMAL(18,6), Received DECIMAL(18,6), 
	Paid DECIMAL(18,6),	Net DECIMAL(18,6), TransactionMode VARCHAR(100), Remarks VARCHAR(MAX));

	DECLARE @temp TABLE (ID INT IDENTITY(1,1),DrawerID INT)

	INSERT INTO @temp
	SELECT [ID] FROM @DrawerIDs

	WHILE(@RowNo <= (SELECT COUNT(*) FROM @temp))
	BEGIN
	    SET @DrawerID = (SELECT DrawerID FROM @temp WHERE ID = @RowNo)			
		
		INSERT INTO	@tbl_Transaction
		EXEC [report].[spGetAccountTransaction] @AccountingDate, @DrawerID	
				
		SET @RowNo = @RowNo + 1;
	END

	SELECT TransactionID, ReservationID, LocationCode, Drawer, AccountGroup, AccountType, CurrencyCode, Amount, Received, Paid, Net, TransactionMode, Remarks 
	FROM @tbl_Transaction 
	ORDER BY AccountGroupID, AccountTypeID
END

