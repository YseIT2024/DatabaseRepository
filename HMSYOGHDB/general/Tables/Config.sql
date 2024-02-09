CREATE TABLE [general].[Config] (
    [ConfigID]    INT           IDENTITY (1, 1) NOT NULL,
    [ConfigValue] VARCHAR (100) NOT NULL,
    [ConfigType]  VARCHAR (50)  NOT NULL,
    [CreatedBy]   INT           NOT NULL,
    [CreatedOn]   VARCHAR (50)  NOT NULL,
    [IsActive]    BIT           NOT NULL,
    CONSTRAINT [PK_Config] PRIMARY KEY CLUSTERED ([ConfigID] ASC) WITH (FILLFACTOR = 90)
);

