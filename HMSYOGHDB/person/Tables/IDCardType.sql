CREATE TABLE [person].[IDCardType] (
    [IDCardTypeID]   INT           IDENTITY (1, 1) NOT NULL,
    [IDCardTypeName] VARCHAR (50)  NOT NULL,
    [Description]    VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_IDCardType] PRIMARY KEY CLUSTERED ([IDCardTypeID] ASC) WITH (FILLFACTOR = 90)
);

