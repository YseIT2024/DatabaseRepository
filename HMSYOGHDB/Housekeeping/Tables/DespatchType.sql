CREATE TABLE [Housekeeping].[DespatchType] (
    [LocationId]       INT           NOT NULL,
    [DespatchTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [DespatchTypeName] VARCHAR (250) NOT NULL,
    [IsActive]         BIT           NOT NULL,
    [CreatedBy]        INT           NOT NULL,
    [CreatedOn]        DATETIME      NOT NULL,
    [ModifiedBy]       INT           NULL,
    [ModifiedOn]       DATETIME      NULL,
    CONSTRAINT [PK_DespatchType] PRIMARY KEY CLUSTERED ([DespatchTypeID] ASC) WITH (FILLFACTOR = 90)
);

