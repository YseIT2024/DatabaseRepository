CREATE TABLE [general].[Image] (
    [ImageID]    INT            IDENTITY (1, 1) NOT NULL,
    [ImageUrl]   VARCHAR (200)  NULL,
    [GuestImage] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Image] PRIMARY KEY CLUSTERED ([ImageID] ASC) WITH (FILLFACTOR = 90)
);

