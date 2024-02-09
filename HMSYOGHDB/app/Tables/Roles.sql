CREATE TABLE [app].[Roles] (
    [RoleId]       INT           IDENTITY (1, 1) NOT NULL,
    [Role]         VARCHAR (50)  NOT NULL,
    [Description]  VARCHAR (100) NULL,
    [IsActive]     BIT           NOT NULL,
    [DisplayOrder] INT           NULL,
    CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED ([RoleId] ASC) WITH (FILLFACTOR = 90)
);

