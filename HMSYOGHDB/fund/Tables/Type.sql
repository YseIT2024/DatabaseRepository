CREATE TABLE [fund].[Type] (
    [FundTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [FundType]   VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_Type_1] PRIMARY KEY CLUSTERED ([FundTypeID] ASC) WITH (FILLFACTOR = 90)
);

