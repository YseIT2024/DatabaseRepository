-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [report].[spGetReservationBill]
(	
@LocationID int,
@Date date
)
AS
BEGIN
	
	--DECLARE @temp1 TABLE(RoomNo int, Folio int, CheckIn date,CheckOut date, Balance varchar(50))

    --SELECT * FROM @temp1

	DECLARE @temp2 TABLE(CheckINDate date, RoomNo int, [Description/Voucher] varchar(100), Charges varchar(50), Credits varchar(50), Balance varchar(50))

    SELECT * FROM @temp2

END










