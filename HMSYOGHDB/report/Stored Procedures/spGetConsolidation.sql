
CREATE PROCEDURE [report].[spGetConsolidation]
(
	@AccountingDate DATE,
	@DrawerIDs as [app].[dtID] readonly,
	@UserLocationID int = null,
	@UserDrawerID int = null,
	@UserID int = null
)
AS
BEGIN
	DECLARE @DrawerID INT = (SELECT MIN(ID) FROM @DrawerIDs)
	DECLARE @TotalReservations INT;
	DECLARE @TotalCheckIn INT;
	DECLARE @TotalCheckOut INT;
	DECLARE @Maintainance INT;
	DECLARE @HouseKeeping INT;
	DECLARE @LOcationID INT = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID)

	EXEC [report].[spGetCashFigureSummary] @AccountingDate,@DrawerIDs
	EXEC [report].[spGetAccountTransactionSummary] @AccountingDate,@DrawerIDs
	EXEC [report].[spGetReconciliationSummary] @AccountingDate,@DrawerIDs
	EXEC [report].[spGetCurrencyRateOfPreviousDate] @AccountingDate,@DrawerID
	EXEC [report].[spGetCurrencyRateOfCurrentDate] @AccountingDate,@DrawerID

	SET @TotalReservations = (SELECT COUNT(ReservationID) FROM reservation.Reservation WHERE LocationID = @LOcationID AND CONVERT(DATE,[DateTime]) = @AccountingDate)
	SET @TotalCheckIn = (SELECT COUNT(ReservationID) FROM reservation.Reservation WHERE LocationID = @LOcationID AND CONVERT(DATE,ActualCheckIn) = @AccountingDate)
	SET @TotalCheckOut = (SELECT COUNT(ReservationID) FROM reservation.Reservation WHERE LocationID = @LOcationID AND CONVERT(DATE,ActualCheckOut) = @AccountingDate)

	SET @Maintainance = (SELECT COUNT(ToDoID) FROM todo.ToDo WHERE LocationID = @LOcationID AND ToDoTypeID =2 AND CONVERT(DATE,EnteredOn) = @AccountingDate)
	SET @HouseKeeping = (SELECT COUNT(ToDoID) FROM todo.ToDo WHERE LocationID = @LOcationID AND ToDoTypeID =1 AND CONVERT(DATE,EnteredOn) = @AccountingDate)

	SELECT @TotalReservations [TotalReservations], @TotalCheckIn [TotalCheckIn], @TotalCheckOut [TotalCheckOut],
	@Maintainance [Maintainance], @HouseKeeping [HouseKeeping] 

	-----Insert in Log Table -----------------
	EXEC [app].[spInsertActivityLog] 4, @UserLocationID , 'Consolidation Report', @UserID
END
