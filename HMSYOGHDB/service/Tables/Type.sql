CREATE TABLE [service].[Type] (
    [ServiceTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [ServiceName]   VARCHAR (100) NOT NULL,
    [Description]   VARCHAR (150) NOT NULL,
    [ShowInUI]      BIT           CONSTRAINT [DF_Type_ShowInUI] DEFAULT ((1)) NOT NULL,
    [InvoiceTitle]  VARCHAR (100) NOT NULL,
    [IsActive]      BIT           NOT NULL,
    [CreatedBy]     INT           NULL,
    [CreatedOn]     DATETIME      NULL,
    [ModifiedBy]    INT           NULL,
    [ModifiedOn]    DATETIME      NULL,
    [IsTaxable]     BIT           NULL,
    CONSTRAINT [PK_Type_2] PRIMARY KEY CLUSTERED ([ServiceTypeID] ASC) WITH (FILLFACTOR = 90)
);

