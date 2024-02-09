create PROCEDURE [report].[spGetCashFigureSummary]
(
	@AccountingDate DATE,
	@DrawerIDs as [app].[dtID] readonly
)
AS
BEGIN
	DECLARE @RowNo int = 1;
	DECLARE @DrawerID int;

	DECLARE @CashFigures TABLE(ID INT IDENTITY(1,1), Currency VARCHAR(6), OpQuantity DECIMAL(25,2), OpUSDValue DECIMAL(25,2),
	ClQuantity DECIMAL(25,2), ClUSDValue DECIMAL(25,2), MovQuantity DECIMAL(25,2), MovUSDValue DECIMAL(25,2))

	DECLARE @temp TABLE (ID INT IDENTITY(1,1),DrawerID INT)

	INSERT INTO @temp
	SELECT [ID] FROM @DrawerIDs

	WHILE(@RowNo <= (SELECT COUNT(*) FROM @temp))
	BEGIN
	    SET @DrawerID = (SELECT DrawerID FROM @temp WHERE ID = @RowNo);			
		
		INSERT INTO	@CashFigures
		EXEC [report].[spGetCashFigures] @AccountingDate, @DrawerID	
				
		SET @rowno = @rowno + 1
	End

	SELECT Currency, SUM(OpQuantity) AS [Open Qty], SUM(OpUSDValue) AS [Open USDValue], SUM(ClQuantity) AS [Close Qty], SUM(ClUSDValue) AS [Close USDValue]
	,SUM(MovQuantity) AS [Mov Qty], SUM(MovUSDValue) AS [Mov USDValue]
	FROM @CashFigures
	GROUP BY Currency
	ORDER BY Currency DESC
END
