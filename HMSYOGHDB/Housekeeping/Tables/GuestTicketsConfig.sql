CREATE TABLE [Housekeeping].[GuestTicketsConfig] (
    [ConfigId]    INT          IDENTITY (1, 1) NOT NULL,
    [ConfigValue] VARCHAR (50) NULL,
    [ConfigType]  VARCHAR (50) NOT NULL,
    [CreatedBy]   INT          NOT NULL,
    [CreatedOn]   DATETIME     NOT NULL,
    [IsActive]    BIT          NOT NULL,
    [ModifiedBy]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
    [ConfigCode]  INT          NULL,
    CONSTRAINT [PK_GuestTicketsConfig] PRIMARY KEY CLUSTERED ([ConfigId] ASC) WITH (FILLFACTOR = 90)
);

