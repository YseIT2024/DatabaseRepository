CREATE TABLE [general].[Customer] (
    [CustomerID]        INT           IDENTITY (1, 1) NOT NULL,
    [ContactID]         INT           NOT NULL,
    [CustomerNo]        VARCHAR (50)  NULL,
    [AccountID]         INT           NULL,
    [IsFromCP]          BIT           NULL,
    [Remarks]           VARCHAR (255) NULL,
    [ReservationTypeID] INT           NULL,
    [CreatedBy]         INT           NULL,
    [CreatedDate]       DATETIME      NULL,
    CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED ([CustomerID] ASC) WITH (FILLFACTOR = 90)
);

