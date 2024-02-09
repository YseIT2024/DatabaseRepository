CREATE TABLE [reservation].[GuestSignatureType] (
    [GuestSignatureTypeID] INT           NOT NULL,
    [GuestSignatureType]   VARCHAR (150) NULL,
    [IsActive]             INT           NULL,
    CONSTRAINT [PK_GuestSignatureType] PRIMARY KEY CLUSTERED ([GuestSignatureTypeID] ASC) WITH (FILLFACTOR = 90)
);

