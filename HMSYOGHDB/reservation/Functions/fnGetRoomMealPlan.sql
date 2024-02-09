
CREATE FUNCTION [reservation].[fnGetRoomMealPlan] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strMealPlan varchar(255);

	--set @strMealPlan =  (
	--SELECT  STRING_AGG(PIT.ItemName, ',')
	--		 from Products.Item PIT 
	--		where PIT.ItemID in (SELECT distinct  RD.ItemID
	--		from reservation.ReservationDetails RD
	--		 where RD.ReservationID=@ReservationId)
	--	)

--	set @strMealPlan =(SELECT  STRING_AGG(RP.ShortName, ',')
--from [Products].[ItemMapRoomPackage] PIT 
--inner join [Products].[RoomPackage] RP on PIT.PackageID = RP.PackageID
--where PIT.ItemID in (SELECT distinct  RD.ItemID
--from reservation.ReservationDetails RD
--where RD.ReservationID=@ReservationId))

--SELECT @strMealPlan = COALESCE(@strMealPlan + ', ', '') + RP.ShortName
--FROM [Products].[ItemMapRoomPackage] PIT 
--INNER JOIN [Products].[RoomPackage] RP ON PIT.PackageID = RP.PackageID
--WHERE PIT.ItemID IN (
--    SELECT DISTINCT RD.ItemID
--    FROM reservation.ReservationDetails RD
--    WHERE RD.ReservationID = @ReservationId
--)

SELECT @strMealPlan = COALESCE(@strMealPlan + ', ', '') +  Price_Type from Products.Item where itemid in (
    SELECT DISTINCT RD.ItemID
    FROM reservation.ReservationDetails RD
    WHERE RD.ReservationID = @ReservationId)
	   
			RETURN @strMealPlan
END
