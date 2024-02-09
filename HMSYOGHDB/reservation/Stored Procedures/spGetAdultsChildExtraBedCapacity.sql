-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 05-09-2023
-- Description:	GET CAPACITY DETAILS 'ADULT AND CHILD AND EXTRA BED'
-- =============================================
CREATE PROCEDURE [reservation].[spGetAdultsChildExtraBedCapacity]
(
@SubCategoryId int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
SELECT  ISNULL(MaxAdditionalBedCapacity,0) AS MaxAdditionalBedCapacity 
      , ISNULL(MaxAdultsCapacity,0) AS MaxAdultsCapacity
      ,ISNULL(MaxChildrensCapacity,0) AS MaxChildrensCapacity
	  ,ISNULL(MaxReservingCapacity,0) AS MaxReservingCapacity
	   FROM  [Products].[SubCategory] where IsActive=1 and SubCategoryID=@SubCategoryId
END


 