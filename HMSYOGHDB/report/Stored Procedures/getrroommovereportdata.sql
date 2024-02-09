CREATE Proc [report].[getrroommovereportdata]
@Date date=null,
@UserId int=null
as
Begin
	--select 207 as Room,'Aniel' as FirstName, 'Nandlal' as LastName,
	--977 as ReservationID,'28-12-2023' as CheckinDate,'29-12-2023' as CheckoutDate,214 as NewRoom,'13:00' as [Time],
	--1 as TotalNight,'Delux Single Bed' as	RoomCategory, 'Tanbir' as RoomMoveBy,
	--'MD Order' as Reason 

	select distinct  x.OldRoomNo as Room
	        ,b.FirstName
			,b.LastName
			--,b.CountryName as Nationality
			--,b.PhoneNumber as Mobile
			,a.ReservationID
	        ,convert(date,a.ActualCheckIn) as CheckinDate
			,convert(date,a.ExpectedCheckOut) as CheckoutDate
			,x.NewRoomno as NewRoom
			,right([dbo].[GetDatetimeBasedonTimezone] (y.[DateTime]),5) as [Time]
			,a.Nights as TotalNight 
			,e.Name as RoomCategory 
			,isnull(n.FirstName,'')+' '+ ISNULL(n.LastName,'') as RoomMoveBy
			,y.Remarks as  Reason
			,y.[DateTime]
		from reservation.Reservation a 
			inner join guest.vwGuestDetails b on a.GuestID=b.GuestID 
			inner join  reservation.ReservationDetails c on c.ReservationID=a.ReservationID
			inner join (select ROW_NUMBER() over (partition by a.ReservationId order by  a.reservedRoomid asc) as id
			, a.reservedRoomid, a.RoomID as OldRoomId,b.RoomID as NewRoomId,c.RoomNo as OldRoomNo,d.RoomNo as NewRoomno,a.ReservationID
from reservation.ReservedRoom a 
inner join reservation.ReservedRoom b on a.RoomID=b.ShiftedRoomID 
and a.ReservationID=b.ReservationID and a.ModifiedDate<=b.ModifiedDate
inner join Products.Room c on c.RoomID=a.RoomID
inner join Products.Room d on d.RoomID=b.RoomID) as x on x.ReservationID=a.ReservationID
inner join (select ROW_NUMBER() over (partition by a.ReservationId order by  a.Id asc) as id,  ReservationID,Remarks,UserID ,[DateTime]
from reservation.ReservationStatusLog  a with (nolock)
where  ReservationStatusID=7) as y on y.ReservationID=x.ReservationID and x.id=y.id
inner join Products.Room h on h.RoomID=x.NewRoomId
inner join Products.SubCategory e on e.SubCategoryID=h.SubCategoryID
			--inner join Products.Item d on d.ItemID=c.ItemID
			--inner join reservation.ReservedRoom g on g.ReservationID=a.ReservationID and g.IsActive=0
			--inner join Products.Room h on h.RoomID=g.RoomID
			--inner join Products.SubCategory e on e.SubCategoryID=h.SubCategoryID
			--inner join Account.TransactionMode f on f.TransactionModeID=a.Hold_TransactionModeID
			--inner join reservation.vwReservationDetails i on a.ReservationID=i.ReservationID
			--inner join j on a.ReservationID=j.ReservationID and j.ReservationStatusID=7
			--inner join reservation.ReservedRoom k on k.ReservationID=a.ReservationID and k.IsActive=1
			--inner join Products.Room l on l.RoomID=k.RoomID
			inner join app.[User] m on m.UserID=y.UserID
			inner join contact.Details n on n.ContactID=m.ContactID
		where  a.ReservationStatusID=3 --and g.ShiftedRoomID is not null

		group by   h.RoomNo  
	        ,b.FirstName
			,b.LastName
		 ,x.NewRoomno
			,a.ReservationID
	        ,convert(date,a.ActualCheckIn) 
			,convert(date,a.ExpectedCheckOut) 
			,x.OldRoomNo  
			,right([dbo].[GetDatetimeBasedonTimezone] (y.[DateTime]),5) 
			,a.Nights 
			,e.Name 
			,isnull(n.FirstName,'')+' '+ ISNULL(n.LastName,'')  
			,y.Remarks 
		 ,y.[DateTime]
		order by y.[DateTime]


End
