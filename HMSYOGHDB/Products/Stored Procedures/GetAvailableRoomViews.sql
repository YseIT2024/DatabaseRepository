CREATE Proc [Products].[GetAvailableRoomViews] --59,'01-Jan-2024','02-Jan-2024',1089

@SubCatgegoryID int,
@ExpectedCheckInDate date,
@ExpectedCheckoutDate date,
@ReservationId int=0
as
Begin
	select distinct SC.Name,RM.RoomID,RM.RoomNo  from  [Products].[Item] IT  
				inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1  
				inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
				INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID  
		where  SC.SubCategoryID =@SubCatgegoryID AND RM.RoomID not in  
				(SELECT a.RoomId from Room.vwOccupiedRooms a where date_id between dateadd(dd,1,(convert(date,@ExpectedCheckInDate)))
				and dateadd(dd,-1,convert(date,@ExpectedCheckoutDate)) and (a.reservationid<>@ReservationId or @ReservationId=0))
		 order by RoomNo



	Select distinct IT.ItemID,SC.Name,RM.RoomID,RM.RoomNo,Fl.[Floor], RM.Remarks,SC.SubCategoryID
	from [reservation].[Reservation] RS
	inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
	inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
	inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1 --and RM.RoomStatusID = 1--Vacant
	inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
	INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID  --- LINE ADD BY MURUGESH S	
	where RS.LocationID =1  -- Hard Coded only For Yogh Hospitality N.V.   
	and IT.ItemID in(select distinct ItemID from [reservation].[ReservationDetails] where ReservationID = @ReservationID)
	AND RM.RoomID not in  (SELECT roomid from Products.RoomLogs where  RoomStatusID not in (1,8) and IsPrimaryStatus=1 
		AND( 
		(Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(ToDate,'yyyy-MM-dd') > Format(@ExpectedCheckInDate,'yyyy-MM-dd')  AND Format(ToDate,'yyyy-MM-dd') < Format(@ExpectedCheckoutDate,'yyyy-MM-dd') ))   OR
         (Format(@ExpectedCheckInDate,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')  AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <Format(ToDate,'yyyy-MM-dd') ))   OR																										
		((Format(fromdate,'yyyy-MM-dd') >Format(@ExpectedCheckInDate,'yyyy-MM-dd')   AND  Format(fromdate ,'yyyy-MM-dd') <  Format(@ExpectedCheckInDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR
		 ((Format(@ExpectedCheckInDate,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')   AND  Format(@ExpectedCheckInDate ,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR

		 
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') > Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd') )  OR
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') <Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') >  Format(ToDate,'yyyy-MM-dd') )  OR 
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') ) OR
		 (Format(@ExpectedCheckInDate,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   OR Format(@ExpectedCheckoutDate,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') )
		 )
		 
		 )
			--AND ( 
			--(Format(@ExpectedCheckInDate,'yyyy-MM-dd')  > Format(fromdate,'yyyy-MM-dd') and Format(@ExpectedCheckInDate,'yyyy-MM-dd')<Format(ToDate,'yyyy-MM-dd') )
			--or 
			--(Format(@ExpectedCheckoutDate,'yyyy-MM-dd')  > Format(fromdate,'yyyy-MM-dd') and Format(@ExpectedCheckoutDate,'yyyy-MM-dd')  < Format(ToDate,'yyyy-MM-dd'))
			--or 
			--(Format(fromdate,'yyyy-MM-dd') > Format(@ExpectedCheckInDate,'yyyy-MM-dd') and Format(fromdate,'yyyy-MM-dd') < Format(@ExpectedCheckoutDate,'yyyy-MM-dd'))
			--or 
			--(Format(ToDate,'yyyy-MM-dd') > Format(@ExpectedCheckInDate,'yyyy-MM-dd') and Format(ToDate,'yyyy-MM-dd') <Format(@ExpectedCheckoutDate,'yyyy-MM-dd'))
			--)
			--)


	 --AND RM.RoomID not in  (SELECT roomid from Products.RoomLogs where   RoomStatusID not in (1,8)
	 --AND ((@ExpectedCheckInDate  between fromdate and ToDate)  
		--	or (@ExpectedCheckoutDate  between fromdate and ToDate) 
		--	or (fromdate between @ExpectedCheckInDate and @ExpectedCheckoutDate) 
		--	or (ToDate between @ExpectedCheckInDate and @ExpectedCheckoutDate)
		--	)
	 --)	
	order by SC.Name  ---ADDED BY MURUGESH S
end