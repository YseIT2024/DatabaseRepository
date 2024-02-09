CREATE TYPE [Restaurant].[dtMenuItem] AS TABLE (
    [ItemID]      INT             NULL,
    [ItemName]    VARCHAR (50)    NULL,
    [ItemCode]    VARCHAR (50)    NULL,
    [Price]       DECIMAL (18, 4) NULL,
    [SubCategory] VARCHAR (50)    NULL,
    [FoodGroup]   VARCHAR (50)    NULL,
    [UOM]         VARCHAR (50)    NULL);

