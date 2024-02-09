-- =============================================
-- Author:		ARABINDA
-- Create date: 24/03/2023
-- Description:	TO GET ROOM DETAILS AS PER SUB CATEGORY ID
-- =============================================

CREATE Proc [room].[spGetRoomdetailBySubCategory] --5,'2021-03-22',1
(		
	@SubCategoryId int 
)
AS
BEGIN	

		--To get Room detail for centre pannel
		IF (@SubCategoryId >0 )
			BEGIN
				SELECT PR.[RoomID],PR.[SubCategoryID],PR.[RoomNo],PR.[FloorID],PR.[LocationID],PR.[Dimension],PR.[BedSize],PR.[MaxAdultCapacity],
				PR.[MaxChildCapacity],PR.[Remarks],PR.[RoomStatusID],PS.[Name]				
				FROM [HMSYOGH].[Products].[Room] PR
				LEFT JOIN Products.SubCategory PS ON PR.SubCategoryID=PS.SubCategoryID
				WHERE PR.[SubCategoryID]=@SubCategoryId
				order by [RoomID]
			END
	
END


