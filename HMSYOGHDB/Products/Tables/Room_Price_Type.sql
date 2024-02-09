CREATE TABLE [Products].[Room_Price_Type] (
    [Price_Type_ID] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Code]          VARCHAR (10) NOT NULL,
    [Name]          VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([Price_Type_ID] ASC) WITH (FILLFACTOR = 90)
);

