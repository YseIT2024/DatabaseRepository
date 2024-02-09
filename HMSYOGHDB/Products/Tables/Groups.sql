CREATE TABLE [Products].[Groups] (
    [GroupID]     INT           IDENTITY (1, 1) NOT NULL,
    [CategoryID]  INT           NOT NULL,
    [GroupCode]   VARCHAR (50)  NOT NULL,
    [Description] VARCHAR (225) NULL,
    [CreatedBy]   INT           NULL,
    [CreatedDate] DATETIME      NULL,
    CONSTRAINT [PK_Products]].[Groups] PRIMARY KEY CLUSTERED ([GroupID] ASC) WITH (FILLFACTOR = 90)
);

