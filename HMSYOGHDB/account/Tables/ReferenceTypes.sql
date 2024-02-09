CREATE TABLE [account].[ReferenceTypes] (
    [ReferenceTypeId] INT           NOT NULL,
    [ReferenceType]   NVARCHAR (50) NULL,
    CONSTRAINT [PK_RefernceTypes] PRIMARY KEY CLUSTERED ([ReferenceTypeId] ASC) WITH (FILLFACTOR = 90)
);

