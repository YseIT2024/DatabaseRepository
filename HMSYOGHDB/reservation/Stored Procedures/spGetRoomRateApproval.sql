-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 2023-09-18
-- Description:	GET ROOM RATE APPROVAL PENDING LIST
-- =============================================
CREATE PROCEDURE [reservation].[spGetRoomRateApproval]
(
@ItemId int,
@LocationId int
)
AS
BEGIN
 
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT [Day] AS WeekDays   FROM Products.RoomDayPrice where ItemID=@ItemId and LocationID=@LocationId and AuthorizedFlag in (1,2) and IsActive=1
END
