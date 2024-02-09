
CREATE PROCEDURE [app].[spInsertActivityLog]
(
	@ActivityTypeID int,   
	@LocationID int,      
    @Activity varchar(max),	
    @UserID int = NULL,	
	@ActivityTitle varchar(250)=null
)
AS
BEGIN
	INSERT INTO [app].[ActivityLog]
	([ActivityTypeID], [LocationID], [Activity], [UserID],ActivityTitle)
	VALUES (@ActivityTypeID, @LocationID, @Activity, @UserID,@ActivityTitle)
END










