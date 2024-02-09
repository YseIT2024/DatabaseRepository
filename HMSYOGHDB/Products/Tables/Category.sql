CREATE TABLE [Products].[Category] (
    [CategoryID]   INT           NOT NULL,
    [Code]         VARCHAR (10)  NOT NULL,
    [Name]         VARCHAR (100) NOT NULL,
    [Remarks]      VARCHAR (200) NULL,
    [IsPreDefined] BIT           NOT NULL,
    [CreatedBy]    INT           NULL,
    [CreateDate]   DATETIME      NULL,
    CONSTRAINT [PK__Category__6DB38D4EF2EFCD20] PRIMARY KEY CLUSTERED ([CategoryID] ASC) WITH (FILLFACTOR = 90)
);

