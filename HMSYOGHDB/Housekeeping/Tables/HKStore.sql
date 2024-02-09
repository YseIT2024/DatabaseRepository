CREATE TABLE [Housekeeping].[HKStore] (
    [LocationId] INT           NOT NULL,
    [StoreID]    INT           IDENTITY (1, 1) NOT NULL,
    [StoreName]  VARCHAR (250) NOT NULL,
    [IsActive]   BIT           NOT NULL,
    [CreatedBy]  INT           NOT NULL,
    [CreatedOn]  DATETIME      NOT NULL,
    CONSTRAINT [PK_HKStore] PRIMARY KEY CLUSTERED ([StoreID] ASC) WITH (FILLFACTOR = 90)
);

