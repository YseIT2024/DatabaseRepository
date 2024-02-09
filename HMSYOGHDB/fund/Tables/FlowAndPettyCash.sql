CREATE TABLE [fund].[FlowAndPettyCash] (
    [ID]          INT IDENTITY (1, 1) NOT NULL,
    [FundFlowID]  INT NOT NULL,
    [PettyCashID] INT NOT NULL,
    CONSTRAINT [PK_FlowAndPettyCash] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_FlowAndPettyCash_Flow] FOREIGN KEY ([FundFlowID]) REFERENCES [fund].[Flow] ([FundFlowID])
);

