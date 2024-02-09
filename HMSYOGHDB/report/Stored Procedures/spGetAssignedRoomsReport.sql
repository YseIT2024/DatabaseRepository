-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetAssignedRoomsReport]
(	
@LocationID int,
@Date date
)
AS
BEGIN
	
	DECLARE @temp TABLE(RoomNo int, ReservationID int, Name varchar(100), CheckIn date,
	CheckOut date, ResvType Varchar(20), ActualType varchar(20), HoldType varchar(20), GroupCode varchar(50), RateCode varchar(20), Entered varchar(50))

	INSERT INTO @temp (RoomNo,ReservationID,Name,CheckIn,CheckOut,ResvType,ActualType,HoldType,GroupCode,RateCode,Entered)
	VALUES (101,1,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF'),
		   (102,2,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF'),
           (103,3,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF'),
		   (104,4,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF'),
		   (105,5,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF'),
		   (106,6,'aaa','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','bbb','ccc','SDG','DAF')

	SELECT * from @temp
END 









