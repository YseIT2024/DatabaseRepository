CREATE TABLE [reservation].[Discount] (
    [DiscountID]  INT             IDENTITY (1, 1) NOT NULL,
    [Percentage]  DECIMAL (18, 2) NOT NULL,
    [Description] VARCHAR (100)   NOT NULL,
    CONSTRAINT [PK_Discount] PRIMARY KEY CLUSTERED ([DiscountID] ASC) WITH (FILLFACTOR = 90)
);

