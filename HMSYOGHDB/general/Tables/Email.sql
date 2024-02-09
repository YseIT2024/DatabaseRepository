CREATE TABLE [general].[Email] (
    [ID]              INT           IDENTITY (1, 1) NOT NULL,
    [FromEmailID]     VARCHAR (200) NOT NULL,
    [FromEmailPswd]   VARCHAR (200) NOT NULL,
    [FromDisplayName] VARCHAR (300) NOT NULL,
    [Host]            VARCHAR (200) NOT NULL,
    [Port]            INT           NOT NULL,
    [BCCEmailId]      VARCHAR (500) NULL,
    [CCEmailId]       VARCHAR (500) NULL,
    CONSTRAINT [PK_general]].[Email] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

