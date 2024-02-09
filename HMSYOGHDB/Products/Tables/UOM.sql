CREATE TABLE [Products].[UOM] (
    [UOMID]       INT          IDENTITY (1, 1) NOT NULL,
    [Code]        VARCHAR (10) NOT NULL,
    [Description] VARCHAR (50) NOT NULL,
    [UOMClassID]  INT          NOT NULL,
    [Predefined]  BIT          NOT NULL,
    CONSTRAINT [PK_UOM] PRIMARY KEY CLUSTERED ([UOMID] ASC) WITH (FILLFACTOR = 90)
);

