

CREATE PROCEDURE [app].[spInsertActivityType]  --'vk','sg','dfg'
(
    --@ActivityTypeID int,           
    @ActivityType varchar(max),    
    @Type nvarchar(max),
    @SubType nvarchar(max)
)
AS
BEGIN
    INSERT INTO [app].[ActivityType]
    ([ActivityType], [Type], [SubType])
    VALUES (@ActivityType, @Type, @SubType)
END
