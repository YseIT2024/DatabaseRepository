-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE PROCEDURE [reservation].[spGetInHouseRoomDetails] --991,1,39
(
	@ResevationID INT,
	@LocationID INT,
	@SubCategory INT

)
AS
BEGIN

	DECLARE @ExpectedCheckIn datetime;
	DECLARE @ExpectedCheckOut Datetime;
	
	SET @ExpectedCheckIn=(SELECT ExpectedCheckIn FROM Reservation.Reservation where ReservationID=@ResevationID)
	SET @ExpectedCheckOut=(SELECT ExpectedCheckOut FROM Reservation.Reservation where ReservationID=@ResevationID)

  --     if(@SubCategory=0)
	 --  BEGIN
		--Select Psc.SubCategoryID,Psc.Name,prm.RoomNo
		--from reservation.ReservedRoom rrr
		--INNER JOIN Products.Room prm ON rrr.RoomID=prm.RoomID
		--INNER JOIN Products.SubCategory  Psc  ON prm.SubCategoryID=psc.SubCategoryID
		--Where rrr.ReservationID=@ResevationID
		--END
		if(@SubCategory>0)
		BEGIN 
			--select distinct IT.ItemID,SC.Name,RM.RoomID,RM.RoomNo,Fl.[Floor], RM.Remarks
			--from [reservation].[Reservation] RS
			--inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
			--inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
			--inner join [Products].[Room] RM on IT.SubCategoryID = RM.SubCategoryID and RM.IsActive = 1 and RM.RoomStatusID = 1--Vacant
			--inner join [Products].[Floor] FL on RM.FloorID= FL.FloorID
			--INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID 
			--where RS.LocationID =1 
			--and IT.ItemID in(select distinct ItemID from [reservation].[ReservationDetails] where ReservationID = @ResevationID And SC.SubCategoryID=@SubCategory)
			----Added by Arabinda on 13/12/2023 to filter only avaiable rooms during the period------
			--AND RM.RoomID not in  (SELECT roomid from Products.RoomLogs where  RoomStatusID >1 
			--and( (@ExpectedCheckIn  between fromdate and ToDate)  or (@ExpectedCheckOut  between fromdate and ToDate)))
			-------------------------------------End----------------------------------------------
			--order by SC.Name  

			select RoomID as ItemID, 'abc' as Name,RoomID,RoomNo,floorid as [Floor], 'bc' from Products.Room where SubCategoryID=@SubCategory
			and IsActive=1 --and RoomStatusID = 1
			and RoomID not in  
			(SELECT roomid from Products.RoomLogs where  RoomStatusID NOT IN (1,8)  
			AND( 
				(Format(@ExpectedCheckIn,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(ToDate,'yyyy-MM-dd') > Format(@ExpectedCheckIn,'yyyy-MM-dd')  AND Format(ToDate,'yyyy-MM-dd') < Format(@ExpectedCheckout,'yyyy-MM-dd') ))   OR
				 (Format(@ExpectedCheckIn,'yyyy-MM-dd') < Format(fromdate,'yyyy-MM-dd')  And (Format(@ExpectedCheckout,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')  AND Format(@ExpectedCheckout,'yyyy-MM-dd') <Format(ToDate,'yyyy-MM-dd') ))   OR																										
				((Format(fromdate,'yyyy-MM-dd') >Format(@ExpectedCheckIn,'yyyy-MM-dd')   AND  Format(fromdate ,'yyyy-MM-dd') <  Format(@ExpectedCheckIn,'yyyy-MM-dd' )) AND Format(@ExpectedCheckout,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR
				 ((Format(@ExpectedCheckIn,'yyyy-MM-dd') >Format(fromdate,'yyyy-MM-dd')   AND  Format(@ExpectedCheckIn ,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd' )) AND Format(@ExpectedCheckout,'yyyy-MM-dd') > Format(ToDate,'yyyy-MM-dd' ))   OR

		 
				 (Format(@ExpectedCheckIn,'yyyy-MM-dd') > Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckout,'yyyy-MM-dd') <  Format(ToDate,'yyyy-MM-dd') )  OR
				 (Format(@ExpectedCheckIn,'yyyy-MM-dd') <Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckout,'yyyy-MM-dd') >  Format(ToDate,'yyyy-MM-dd') )  OR 
				 (Format(@ExpectedCheckIn,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   AND Format(@ExpectedCheckout,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') ) OR
				 (Format(@ExpectedCheckIn,'yyyy-MM-dd') = Format(fromdate,'yyyy-MM-dd')   OR Format(@ExpectedCheckout,'yyyy-MM-dd') =  Format(ToDate,'yyyy-MM-dd') )
			  )
		 
			)
			--and( (@ExpectedCheckIn  between fromdate and ToDate)  or (@ExpectedCheckOut  between fromdate and ToDate)
			--or (fromdate between @ExpectedCheckIn and @ExpectedCheckOut) or (ToDate between @ExpectedCheckIn and @ExpectedCheckOut)
			--))



			END
	
			
END

  
	






