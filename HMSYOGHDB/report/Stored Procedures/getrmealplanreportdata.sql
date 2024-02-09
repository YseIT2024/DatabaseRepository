CREATE Proc report.getrmealplanreportdata
@Date date,
@UserId int
as
Begin
	select 207 as Room,'Aniel' as FirstName, 'Nandlal' as LastName,
	977 as ReservationID,'29-Dec-2023' as CheckoutDate,'13:00' as Occupancy,
	'CP' as RoomPlan,'MD Reference' as BookingSource
End
