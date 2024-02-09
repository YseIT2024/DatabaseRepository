CREATE TYPE [Products].[ComboItem] AS TABLE (
    [ComboItemID] INT             NULL,
    [Comboitem]   VARCHAR (50)    NULL,
    [SubCategory] VARCHAR (50)    NULL,
    [Price]       DECIMAL (18, 2) NULL,
    [Quantity]    INT             NULL);

