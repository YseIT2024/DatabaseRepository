CREATE TABLE [Inventory].[PurchaseIndent] (
    [PIID]         INT           IDENTITY (1, 1) NOT NULL,
    [PINo]         VARCHAR (50)  NOT NULL,
    [DeaprtmentID] INT           NOT NULL,
    [LocationID]   INT           NOT NULL,
    [Remarks]      VARCHAR (255) NULL,
    [CreatedBy]    INT           NOT NULL,
    [CreatedDate]  DATETIME      NOT NULL,
    CONSTRAINT [PK_PurchaseIndent] PRIMARY KEY CLUSTERED ([PIID] ASC) WITH (FILLFACTOR = 90)
);

