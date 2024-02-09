CREATE TABLE [app].[UserRoleObjects] (
    [UserRoleObjectID] INT IDENTITY (1, 1) NOT NULL,
    [RoleID]           INT NOT NULL,
    [ObjectID]         INT NOT NULL,
    [OperationID]      INT NOT NULL
);

