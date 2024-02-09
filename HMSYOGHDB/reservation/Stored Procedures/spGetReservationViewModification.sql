


CREATE PROCEDURE [reservation].[spGetReservationViewModification]   --6545,1,'2024-01-24','2024-01-26',42,1
(	
	@ReservationID int,
	@LocationID int,
	@ExpectedCheckInDate datetime,
	@ExpectedCheckOutDate datetime,
	@ItemIds int=0,
	@DrawerID int =0
)
AS
BEGIN
	
	--Declare @ReservationID int=6037,@LocationID int,@DrawerID int 
	SET NOCOUNT ON;	

	--DECLARE @ActualCheckIn datetime;
	--DECLARE @ActualStay int;
	--DECLARE @Nights int;	spGetReservationViewModification
	DECLARE @ReservationStatusID int;
	--DECLARE @RateCurrencyID int;
	--DECLARE @CurrencyID int;
	--DECLARE @DateDifference int;
	--DECLARE @ExpectedCheckInDate datetime;
	--DECLARE @ExpectedCheckOutDate datetime;
	--DECLARE @RequiredReservationDeposit decimal;
	--DECLARE @CurrencyCode varchar(20) = (Select CurrencyCode from [currency].[Currency] where CurrencyID=1)


    select distinct 1 ItemID,SC.Name,RM.RoomID,CONCAT(RM.RoomNo,'-',pr.RoomStatus)as RoomNo,Fl.[Floor], RM.Remarks,SC.SubCategoryID
	from  [Products].[Item] IT --on RD.ItemID = IT.ItemID
	inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1 
	inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
	INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID   
	Inner join Products.RoomStatus pr ON Rm.RoomStatusID = pr.RoomStatusID 
	where SC.SubCategoryID  = @ItemIds
	--and IT.ItemID = 42 -- in  (@ItemIds)   --(SELECT Ltrim(RTrim(Value)) FROM STRING_SPLIT(@ItemIds, ','))
	AND RM.RoomID not in  
				(SELECT a.RoomId from Room.vwOccupiedRooms a where date_id between dateadd(dd,1,(convert(date,@ExpectedCheckInDate)))
				and dateadd(dd,-1,convert(date,@ExpectedCheckOutDate)) and (a.reservationid<>@ReservationId or @ReservationId=0))



	--AND RM.RoomID not in  (SELECT roomid from Products.RoomLogs where  RoomStatusID not in (1,8) and IsPrimaryStatus=1 
	--	AND( 
	--	(Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(ToDate,'yyyy-MM-dd') > Format(@ExpectedCheckInDate,'yyyy-MM-dd')  AND Format(ToDate,'yyyy-MM-dd') < Format(@ExpectedCheckoutDate,'yyyy-MM-dd') ))   OR
 --        (Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')  AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <Format(ToDate,'yyyy-MM-dd') ))   OR																										
	--	((Format(fromdate,'yyyy-MM-dd') >Format(@ExpectedCheckInDate,'yyyy-MM-dd')   AND  Format(fromdate ,'yyyy-MM-dd') <  Format(@ExpectedCheckInDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR
	--	 ((Format(@ExpectedCheckInDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')   AND  Format(@ExpectedCheckInDate ,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR

		 
	--	 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') > Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd') )  OR
	--	 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') <Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >  Format(ToDate,'yyyy-MM-dd') )  OR 
	--	 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') ) OR
	--	 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   OR Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') )
	--	 )		 
	--	 )
			
	order by SC.Name  ---ADDED BY MURUGESH S



	End