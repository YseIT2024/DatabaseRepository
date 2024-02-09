CREATE PROC [Housekeeping].[usp_HKLostItemDispose_Pageload]	
	@UserId int,
	@LocationID INT	      
   
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @IsSuccess bit = 0;
		DECLARE @Message varchar(max) = '';
		--DECLARE @ContactID int;
		--DECLARE @GenderID int;
		--Declare @ImageID int;
		--DECLARE @Location varchar(20) = (SELECT LocationCode FROM general.Location  WHERE LocationID = @LocationID )
		--DECLARE @Title varchar(200);
		--DECLARE @Actvity varchar(max);  
		
		SELECT [DisposeTypeID], [DisposeTypeName] FROM [HMSYOGH].[Housekeeping].[DisposeType]	WHERE  [IsActive] =1

		SELECT	[DespatchTypeID],[DespatchTypeName]     FROM [HMSYOGH].[Housekeeping].[DespatchType]	WHERE [IsActive]=1
      

	
END	


