CREATE TABLE [reservation].[ServicePayment] (
    [ID]            INT IDENTITY (1, 1) NOT NULL,
    [ServiceID]     INT NOT NULL,
    [TransactionID] INT NOT NULL,
    CONSTRAINT [PK_ServicePayment] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServicePayment_Service] FOREIGN KEY ([ServiceID]) REFERENCES [reservation].[Service] ([ServiceID])
);

