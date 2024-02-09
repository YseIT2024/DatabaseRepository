CREATE TABLE [reservation].[ProcessType] (
    [ProcessTypeId] INT            NOT NULL,
    [ProcessType]   NVARCHAR (150) NULL,
    [IsActive]      INT            NULL,
    CONSTRAINT [PK_ProcessType] PRIMARY KEY CLUSTERED ([ProcessTypeId] ASC) WITH (FILLFACTOR = 90)
);

