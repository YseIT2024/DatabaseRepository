-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetGuestsToCheckOut]
(	
@LocationID int,
@Date date
)
AS
BEGIN
	
	DECLARE @temp TABLE(RoomNo int, Name varchar(100), CheckIn date,
	CheckOut date, [Adult/Children] varchar(5), RateCode Varchar(20), Rate1 varchar(20), Rate2 varchar(20), Discount varchar(50), PayType varchar(20), Balance varchar(50))
	INSERT INTO @temp (RoomNo, Name, CheckIn, CheckOut, [Adult/Children], RateCode, Rate1, Rate2, Discount, PayType, Balance)
	Values
	(101,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(102,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(103,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(104,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(105,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(106,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg'),
	(107,'In-House','03-Oct-2019','09-Nov-2019','GDHJF','DFSG','SDG','DAF','kjh','jkj','khjhjg')
    SELECT * FROM @temp

END








