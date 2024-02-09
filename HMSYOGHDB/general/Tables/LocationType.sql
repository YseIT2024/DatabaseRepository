CREATE TABLE [general].[LocationType] (
    [LocationTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [CategoryID]     INT           NULL,
    [LocationType]   VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_CompanyType] PRIMARY KEY CLUSTERED ([LocationTypeID] ASC) WITH (FILLFACTOR = 90)
);

