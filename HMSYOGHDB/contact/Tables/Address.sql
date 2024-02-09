CREATE TABLE [contact].[Address] (
    [AddressID]     INT          IDENTITY (1, 1) NOT NULL,
    [AddressTypeID] INT          NOT NULL,
    [ContactID]     INT          NOT NULL,
    [Street]        VARCHAR (50) NULL,
    [City]          VARCHAR (30) NULL,
    [State]         VARCHAR (30) NULL,
    [ZipCode]       VARCHAR (10) NULL,
    [CountryID]     INT          NOT NULL,
    [Email]         VARCHAR (50) NULL,
    [PhoneNumber]   VARCHAR (15) NULL,
    [IsDefault]     BIT          CONSTRAINT [DF_Address_IsDefault] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED ([AddressID] ASC) WITH (FILLFACTOR = 90)
);

