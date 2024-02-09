

CREATE PROCEDURE [room].[uspGetBlockedRoom] --1
--(
--@SelectedRoomID INT = null
--)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT SC.Name, R.RoomID,R.RoomNo,SC.SubCategoryID
	FROM [Products].[Room] R
	INNER JOIN [Products].[SubCategory] SC ON R.SubCategoryID = SC.SubCategoryID
	--where R.RoomStatusID=1
	order by RoomID


	SELECT BR.[BlockedId], BR.[RoomID],BR. [FromDate], BR.[ToDate], BR.[Status], BR.[IsActive],BR. [CreatedBy], BR.[CreatedOn] ,rt.SubCategoryID,rt.Name,BR.Remarks,RoomNo,Co.ConfigID As blockTypeId ,Co.ConfigValue As blockType
    FROM [Products].[BlockedRoom] BR
	INNER JOIN [Products].[Room] Pr ON BR.RoomID = Pr.RoomID
	LEFT JOIN Products.SubCategory rt ON PR.SubCategoryID = rt.SubCategoryID 
	INNER JOIN [general].[Config] CO ON BR.blockTypeId = CO.ConfigID 
	Where Pr.RoomStatusID =10
	ORDER BY BR.BlockedId
	
	SELECT [ConfigID] as blockTypeId, [ConfigValue] as blockType FROM [general].[Config] where [ConfigType] =3 and [IsActive] = 1

	--SELECT [ConfigValue], [ConfigType] FROM [general].[Config] Where ConfigType =3


END










