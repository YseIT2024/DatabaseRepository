CREATE TABLE [reservation].[ServiceDetails] (
    [ServiceDetailsID] INT IDENTITY (1, 1) NOT NULL,
    [ServiceID]        INT NOT NULL,
    [ItemID]           INT NOT NULL,
    [ItemRateID]       INT NOT NULL,
    [Quantity]         INT NOT NULL,
    CONSTRAINT [PK_ServiceDetails] PRIMARY KEY CLUSTERED ([ServiceDetailsID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ServiceDetails_Service] FOREIGN KEY ([ServiceID]) REFERENCES [reservation].[Service] ([ServiceID])
);

