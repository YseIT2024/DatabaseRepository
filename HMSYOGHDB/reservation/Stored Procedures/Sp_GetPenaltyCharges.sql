CREATE proc [reservation].[Sp_GetPenaltyCharges]
(
@SubCategoryID int
)
AS
BEGIN

SELECT TimeId,EarlyCheckInCharges,LateCheckOutCharges,SubcategoryId   FROM [reservation].[PenaltyCharges] where SubcategoryId=@SubCategoryID

END