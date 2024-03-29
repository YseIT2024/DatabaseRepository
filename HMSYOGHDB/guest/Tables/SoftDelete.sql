﻿CREATE TABLE [guest].[SoftDelete] (
    [SDID]       INT           IDENTITY (1, 1) NOT NULL,
    [CUSTOMERID] INT           NOT NULL,
    [REASON]     VARCHAR (100) NOT NULL,
    [SDSTATUS]   VARCHAR (10)  NOT NULL,
    [CREATEDON]  DATETIME      NOT NULL,
    [CREATEDBY]  INT           NOT NULL,
    [MODIFIEDON] DATETIME      NULL,
    [MODIFIEDBY] INT           NULL,
    [IsActive]   BIT           NOT NULL,
    CONSTRAINT [PK_SoftDelete] PRIMARY KEY CLUSTERED ([SDID] ASC) WITH (FILLFACTOR = 90)
);

