create PROCEDURE [reservation].[spGetReservationCancellationLoadData] --6032, 1, 1
(	
	@ReservationID int,
	@LocationID int,
	@DrawerID int,
	@RequestedOn Datetime
)
AS
BEGIN
	SET NOCOUNT ON;	
		Declare @DateDifference int, @Nights int
		Declare @ExpectedCheckIn DateTime;

		select @ExpectedCheckIn= ExpectedCheckIn  from [reservation].[Reservation] where ReservationID = @ReservationID

		select @Nights = Nights  from  [reservation].[Reservation] where ReservationID = @ReservationID

		set @DateDifference=DATEDIFF(DAY,@ExpectedCheckIn, @RequestedOn)

		if @DateDifference <0 set @DateDifference=0

		select NightDate,Rooms, LineTotal from [reservation].[ReservationDetails]
		where ReservationID = @ReservationID 			

		SELECT isnull(min(CancellationPercent),100) as CancellationFeePercent FROM  [reservation].[StandardCancellationCharges]
				where  (@DateDifference >=CancellationDayFrom and @DateDifference <=CancellationDayTo)
				      and (@Nights >= NightsFrom and @Nights <= NightsTo)

		select [ReservationModeID] ,[ReservationMode]
		FROM [reservation].[ReservationMode]
	
END
