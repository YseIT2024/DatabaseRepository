-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [app].[spGetTableStructureDetails] 
	(
	 @LocationID int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	  select struct.[LocationId], struct.[NoOfTables], structDet.[TableID], structDet.[StructureID],structDet.[TableNo], 
  structDet.[MaxCapacity], structDet.[Description],structDet.[StatusID], ststus.[Status], struct.[BookingCapacity]
  FROM  [Restaurant].[Structure] struct
  Inner Join  [Restaurant].[StructureDetails] structDet on struct.StructureID = structDet.StructureID
  Inner Join  [Restaurant].[TableStatus] ststus on structDet.[StatusID] = ststus.[StatusID]
  where struct.[LocationId] = @LocationID

END



