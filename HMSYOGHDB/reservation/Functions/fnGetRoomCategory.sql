
create FUNCTION [reservation].[fnGetRoomCategory] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strRoomCategory varchar(255);


	--declare @SubCategoryId int;

	--set @SubCategoryId =(SELECT distinct PIT.SubCategoryID
	--							from reservation.ReservationDetails RD
	--							inner join Products.Item PIT on RD.ItemID=PIT.ItemID
	--							where RD.ReservationID=@ReservationId)

	--set @strRoomCategory = (SELECT STRING_AGG(PSC.Name, ',') 
	--								from   Products.SubCategory PSC  
	--								where PSC.SubCategoryID in (SELECT distinct PIT.SubCategoryID
	--							from reservation.ReservationDetails RD
	--							inner join Products.Item PIT on RD.ItemID=PIT.ItemID
	--							where RD.ReservationID=@ReservationId))

	--		RETURN @strRoomCategory

	--DECLARE @strRoomCategory NVARCHAR(MAX)

	SELECT @strRoomCategory = COALESCE(@strRoomCategory + ', ', '') + PSC.Name
	FROM Products.SubCategory PSC
	WHERE PSC.SubCategoryID IN (
		SELECT DISTINCT PIT.SubCategoryID
		FROM reservation.ReservationDetails RD
		INNER JOIN Products.Item PIT ON RD.ItemID = PIT.ItemID
		WHERE RD.ReservationID = @ReservationId
	)

	RETURN @strRoomCategory


END





