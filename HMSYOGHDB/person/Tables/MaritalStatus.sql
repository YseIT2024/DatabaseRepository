CREATE TABLE [person].[MaritalStatus] (
    [MaritalStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [MaritalStatus]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MaritalStatus] PRIMARY KEY CLUSTERED ([MaritalStatusID] ASC) WITH (FILLFACTOR = 90)
);

