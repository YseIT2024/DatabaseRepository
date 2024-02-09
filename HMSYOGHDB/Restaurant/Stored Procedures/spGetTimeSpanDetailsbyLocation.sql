-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [Restaurant].[spGetTimeSpanDetailsbyLocation] 
	(
	 @LocationID int,
	 @CategoryID int
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 

  SELECT tmSlot.[CategoryID], cat.[Name] as Category, tmSlot.[LocationId], loc.LocationName as [Location], 
		 tmSlot.[TimeSlotsID],tmSlot.[FromTime],tmSlot.[MealTypeID]  ,mlType.[MealType]    
		  FROM  [Restaurant].[TimeSlots] tmSlot
		  INNER JOIN  [Restaurant].[MealType] mlType
		  ON tmSlot.MealTypeID = mlType.MealTypeID
		  INNER JOIN  [Products].[Category] cat
		  ON tmSlot.[CategoryID] = cat.[CategoryID]
		  INNER JOIN  [general].[Location] loc
		  ON tmSlot.[LocationID] = loc.[LocationID]
		  WHERE cat.CategoryID = @CategoryID and tmSlot.[LocationId] = @LocationID
		  ORDER BY tmSlot.MealTypeID  

END



