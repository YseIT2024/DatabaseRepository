CREATE TABLE [fund].[FlowStatus] (
    [FundFlowStatusID] INT          IDENTITY (1, 1) NOT NULL,
    [FundFlowStatus]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_FlowStatus] PRIMARY KEY CLUSTERED ([FundFlowStatusID] ASC) WITH (FILLFACTOR = 90)
);

