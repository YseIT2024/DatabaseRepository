CREATE TABLE [guest].[BlackListTypes] (
    [BlackListTypeID]   TINYINT      NOT NULL,
    [BlackListTypeName] VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_BlackListTypes] PRIMARY KEY CLUSTERED ([BlackListTypeID] ASC) WITH (FILLFACTOR = 90)
);

