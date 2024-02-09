CREATE TABLE [Products].[PriceType] (
    [PriceTypeID]   INT           NOT NULL,
    [Name]          VARCHAR (100) NOT NULL,
    [Remarks]       VARCHAR (200) NULL,
    [Discount]      VARCHAR (10)  NULL,
    [BasePriceType] INT           NULL,
    [CreatedBy]     INT           NULL,
    [CreateDate]    DATETIME      NULL,
    CONSTRAINT [PK__Price_Ty__629676B09D09F547] PRIMARY KEY CLUSTERED ([PriceTypeID] ASC) WITH (FILLFACTOR = 90)
);

