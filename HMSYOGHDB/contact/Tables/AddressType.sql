CREATE TABLE [contact].[AddressType] (
    [AddressTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [AddressType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_AddressType] PRIMARY KEY CLUSTERED ([AddressTypeID] ASC) WITH (FILLFACTOR = 90)
);

