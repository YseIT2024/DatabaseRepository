CREATE Proc [report].[getguestpreferencereportdata] --'12/24/2023' , 75
@Date date,
@UserId int
as
Begin
	select 207 as Room,'Aniel' as FirstName, 'Nandlal' as LastName,'Guyana' as Nationality,'597222333'as Mobile,
	977 as ReservationID,'28-Dec-2023' as CheckinDate,'19:00' as ArrivalTime,'29-Dec-2023' as CheckoutDate,'12:00:00 PM' as	Departuretime,
	1 as TotalNight,'Delux Single Bed' as	RoomCategory,'1 Adult and 0 kid' as Occupancy, 'CP' as	RoomPlan,'01-Dec-2020' as Birthdaydate,'Need Wifi kjfdgdjf dfljgdflkjg edfkljgdnvd sdfgkjdlk ssdjfsdkjfsdkj sfsdf vijv
	 Need Wifi kjfdgdjf dfljgdflkjg edfkljgdnvd sdfgkjdlk ssdjfsdkjfsdkj sfsdf vijv' as GuestRequest,
	'MD Reference' as BookingSource,'Complimentary'as Payment  
End