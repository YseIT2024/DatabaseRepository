CREATE TABLE [guest].[Blacklist_History] (
    [BLID]          INT           NOT NULL,
    [CUSTOMERID]    INT           NOT NULL,
    [REASON]        VARCHAR (100) NOT NULL,
    [BLTYPEID]      INT           NOT NULL,
    [EFFECTIVEFROM] DATETIME      NOT NULL,
    [REQUESTEDBY]   INT           NULL,
    [BLSTATUS]      VARCHAR (10)  NOT NULL,
    [REMOVEDDATE]   DATETIME      NULL,
    [REMOVEDBY]     INT           NULL,
    [CREATEDON]     DATETIME      NOT NULL,
    [CREATEDBY]     INT           NOT NULL,
    [MODIFIEDON]    DATETIME      NULL,
    [MODIFIEDBY]    INT           NULL,
    [IsActive]      BIT           NOT NULL
);

