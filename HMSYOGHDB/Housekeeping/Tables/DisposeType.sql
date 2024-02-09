CREATE TABLE [Housekeeping].[DisposeType] (
    [LocationId]      INT           NOT NULL,
    [DisposeTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [DisposeTypeName] VARCHAR (250) NOT NULL,
    [IsActive]        BIT           NOT NULL,
    [CreatedBy]       INT           NOT NULL,
    [CreatedOn]       DATETIME      NOT NULL,
    [ModifiedBy]      INT           NULL,
    [ModifiedOn]      DATETIME      NULL,
    CONSTRAINT [PK_DisposeType] PRIMARY KEY CLUSTERED ([DisposeTypeID] ASC) WITH (FILLFACTOR = 90)
);

