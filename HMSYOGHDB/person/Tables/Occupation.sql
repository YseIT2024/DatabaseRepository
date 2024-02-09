CREATE TABLE [person].[Occupation] (
    [OccupationID] INT          IDENTITY (1, 1) NOT NULL,
    [Occupation]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Occupation] PRIMARY KEY CLUSTERED ([OccupationID] ASC) WITH (FILLFACTOR = 90)
);

