CREATE Proc report.getlatecheckoutreportdata
@Date date,
@UserId int
as
Begin
	select 207 as Room,'Aniel' as FirstName, 'Nandlal' as LastName,'Guyana' as Nationality,'597222333'as Mobile,
	977 as ReservationID,GetDate() as CheckinDate,'19:00' as ArrivalTime,GetDate() as CheckoutDate,'12:00:00 PM' as	Departuretime,
	1 as TotalNight,'Delux Single Bed' as	RoomCategory,'1 Adult and 0 kid' as Occupancy, 'CP' as	RoomPlan,
	'0.00' as	RoomRate,'100.00' as latecheckoutrate, '100.00' as	Total, '0.00' as Balanace,
	'MD Reference' as BookingSource,'Complimentary'as Payment  
End