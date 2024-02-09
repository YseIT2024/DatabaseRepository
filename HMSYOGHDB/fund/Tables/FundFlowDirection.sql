CREATE TABLE [fund].[FundFlowDirection] (
    [FundFlowDirectionID] INT           IDENTITY (1, 1) NOT NULL,
    [FundFlowDirection]   VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_FundFlowDirection] PRIMARY KEY CLUSTERED ([FundFlowDirectionID] ASC) WITH (FILLFACTOR = 90)
);

