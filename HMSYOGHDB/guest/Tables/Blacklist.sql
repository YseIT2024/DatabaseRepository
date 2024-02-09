CREATE TABLE [guest].[Blacklist] (
    [BLID]          INT           IDENTITY (1, 1) NOT NULL,
    [CUSTOMERID]    INT           NOT NULL,
    [REASON]        VARCHAR (100) NOT NULL,
    [BLTYPEID]      INT           NOT NULL,
    [EFFECTIVEFROM] DATETIME      NOT NULL,
    [REQUESTEDBY]   INT           NULL,
    [BLSTATUS]      VARCHAR (50)  NOT NULL,
    [REMOVEDDATE]   DATETIME      NULL,
    [REMOVEDBY]     INT           NULL,
    [CREATEDON]     DATETIME      NOT NULL,
    [CREATEDBY]     INT           NOT NULL,
    [MODIFIEDON]    DATETIME      NULL,
    [MODIFIEDBY]    INT           NULL,
    [IsActive]      INT           NOT NULL,
    CONSTRAINT [PK_Blacklist] PRIMARY KEY CLUSTERED ([BLID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Blacklist_Customer] FOREIGN KEY ([BLID]) REFERENCES [general].[Customer] ([CustomerID])
);

