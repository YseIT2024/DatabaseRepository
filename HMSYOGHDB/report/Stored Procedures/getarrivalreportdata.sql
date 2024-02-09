CREATE Proc [report].[getarrivalreportdata] --'29-Dec-2023',1
@Date date,
@UserId int
as
Begin
	--select 977 as  ReservationID,	'28.12.2023' as CheckinDate,'19:00' as 	ArrivalTime
	--,'29.12.2023' as CheckoutDate,	'12:00' as Departuretime,	1 as TotalNight,'Delux Single Bed' as	RoomCategory,	
	--'1 Adult and 0 kid' as Occupancy, 'CP' as	RoomPlan,'$0.00' as	RoomRate,	'$0.00'  as Total,
	--'$0.00'  as Balanace, 'MD Reference' as	BookingSource,	'Complimentary'as Payment 

	select  
			h.RoomNo as Room
	        ,b.FirstName
			,b.LastName
			,b.CountryName as Nationality
			,PhoneNumber as Mobile	
			,a.ReservationID
	        ,convert(date,a.ExpectedCheckIn) as CheckinDate
		     ,right([dbo].[GetDatetimeBasedonTimezone] (a.ExpectedCheckIn),5) as 	ArrivalTime	 
			,convert(date,a.ExpectedCheckOut) as CheckoutDate
			,right([dbo].[GetDatetimeBasedonTimezone] (a.ExpectedCheckOut),5) as Departuretime		
			,Nights as TotalNight 
			,e.Name as RoomCategory
			,convert(varchar(50),a.Adults+a.ExtraAdults)+' Adult and '+convert(varchar(50),a.Children+a.ExtraChildJu+a.ExtraChildSe) +' Kid' as  Occupancy
			,ItemName as RoomPlan
			,max(LineTotal) as RoomRate
			,TotalPayable as Total
			,RequiredAMT as Balanace
			,'' as BookingSource
			,TransactionMode as Payment
		from reservation.Reservation a 
		 
			inner join guest.vwGuestDetails b on a.GuestID=b.GuestID 
			inner join  reservation.ReservationDetails c on c.ReservationID=a.ReservationID
			inner join Products.Item d on d.ItemID=c.ItemID
			inner join reservation.ReservedRoom g on g.ReservationID=a.ReservationID
			inner join Products.Room h on h.RoomID=g.RoomID
			inner join Products.SubCategory e on e.SubCategoryID=h.SubCategoryID
			inner join Account.TransactionMode f on f.TransactionModeID=a.Hold_TransactionModeID
		where Convert(date,[dbo].[GetDatetimeBasedonTimezone](a.ExpectedCheckIn))= @Date and ReservationStatusID= 1
	
		group by a.ReservationID,a.ExpectedCheckIn,a.ExpectedCheckOut,Nights,
		e.Name, a.Adults,a.ExtraAdults,a.Children,a.ExtraChildJu,a.ExtraChildSe, ItemName,
		TotalPayable, RequiredAMT , TransactionMode,h.RoomNo 
	        ,b.FirstName
			,b.LastName
			,b.CountryName 
			,PhoneNumber 
		order by 2
End


