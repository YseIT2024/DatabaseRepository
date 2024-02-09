
CREATE PROCEDURE [room].[spGetRoomDashboard] --5,'2021-03-22',1
(	
	@LocationID int =null,
	--@Date datetime =null,
	@UserID int = null,
	@SubCategoryId int =null
)
AS
BEGIN	
	
	--To get Total Inventory for right pannel

		--IF (@SubCategoryId >0 )
		--	SELECT COUNT(*) as TotalInventory FROM [HMSYOGH].[Products].[Room] WHERE [IsActive]=1 AND @SubCategoryId =@SubCategoryId 
		--ELSE
			SELECT COUNT(*) as TotalInventory FROM [HMSYOGH].[Products].[Room] WHERE [IsActive]=1 
		
	  --To get Room category for left pannel

		SELECT PS.[SubCategoryID],PS.[CategoryID],PS.[Code],PS.[Name],PS.[Description],PS.[Remarks],
		PS.[MaxReservingCapacity],PS.[MaxChildAge],PS.[TotalInventory],
		PS.Online_Listing,
		(SELECT count(RoomID) from products.room where RoomStatusID=1 and SubCategoryID=ps.SubCategoryID) Vacant
		FROM [HMSYOGH].[Products].[SubCategory] PS
		WHERE CategoryId=1 and [IsActive] =1 --and SubCategoryID=39


-----------------------------Start----------------------------------------------------------------------------------

			--SELECT 
			--	SC.[SubCategoryID], SC.[CategoryID], SC.[Code], SC.[Name], SC.[Description], 
			--	SC.[Remarks], SC.[MaxReservingCapacity], SC.[MaxChildAge], SC.[TotalInventory],
			--	COUNT(R.[RoomID]) AS RoomCount
			--FROM 
			--	[HMSYOGH].[Products].[SubCategory] SC
			--LEFT JOIN 
			--	[HMSYOGH].[Products].[Room] R ON SC.[SubCategoryID] = R.[SubCategoryID] AND R.[IsActive] = 1
			--WHERE 
			--	SC.[CategoryId] = 1 AND SC.[IsActive] = 1
			--GROUP BY 
			--	SC.[SubCategoryID], SC.[CategoryID], SC.[Code], SC.[Name], SC.[Description], 
			--	SC.[Remarks], SC.[MaxReservingCapacity], SC.[MaxChildAge], SC.[TotalInventory];

-----------------------------End----------------------------------------------------------------------------------

		--To get Status wise room count
		IF (@SubCategoryId >0 )
			BEGIN
				SELECT  PR.[RoomStatusID],
				(SELECT [RoomStatus] FROM [HMSYOGH].[Products].[RoomStatus] WHERE [RoomStatusID]=PR.[RoomStatusID]) AS RoomStatus,
				COUNT(*) as [Count]  FROM [HMSYOGH].[Products].[Room] PR WHERE [IsActive]=1 AND  [SubCategoryID]=@SubCategoryId
				GROUP BY [RoomStatusID]	ORDER BY [RoomStatusID]				
			END
		ELSE
			BEGIN
				SELECT  PR.[RoomStatusID],
				 (SELECT [RoomStatus] FROM [HMSYOGH].[Products].[RoomStatus] WHERE [RoomStatusID]=PR.[RoomStatusID]) AS RoomStatus,
				COUNT(*) as [Count]  FROM [HMSYOGH].[Products].[Room] PR WHERE [IsActive]=1 
				GROUP BY [RoomStatusID]	ORDER BY [RoomStatusID]
			END

		--To get Room detail for centre pannel
		IF (@SubCategoryId >0 )
			BEGIN
				SELECT [RoomID],[SubCategoryID],[RoomNo],[FloorID],[LocationID],[Dimension],[BedSize],[MaxAdultCapacity]
				,[MaxChildCapacity],[Remarks],[RoomStatusID],
				1 as ReservationId,
				'A' as GuestName,
				1 AS AdultCount,
				2 AS ChildCount,
				'2' as CheckInDate,
				'3' as CheckoutDate,
				isnull((select top 1 code  from Products.SubCategory where SubCategoryID=room.SubCategoryID),'')+'-'+convert(varchar(50),[RoomNo]) as RoomDesc
				FROM [HMSYOGH].[Products].[Room]  room
				WHERE [SubCategoryID]=@SubCategoryId
				order by [RoomID]
			END
		ELSE
			BEGIN
				SELECT [RoomID],[SubCategoryID],[RoomNo],'Floor: ' + LTRIM(STR([FloorID])) as FloorID,[LocationID],isnull([Dimension],0) as [Dimension],isnull([BedSize],0) as [BedSize],isnull([MaxAdultCapacity],0) as [MaxAdultCapacity]
				,isnull([MaxChildCapacity],0) as [MaxChildCapacity],isnull([Remarks],'') as [Remarks],[RoomStatusID],
				1 as ReservationId,
				'A' as GuestName,
				1 AS AdultCount,
				2 AS ChildCount,
				'2' as CheckInDate,
				'3' as CheckoutDate,
			 	isnull((select top 1 code  from Products.SubCategory where SubCategoryID=room.SubCategoryID),'')+'-'+convert(varchar(50),[RoomNo]) as RoomDesc
				FROM [HMSYOGH].[Products].[Room] room 
				WHERE [IsActive]=1 	order by [SubCategoryID],[RoomID]
			 END
END


