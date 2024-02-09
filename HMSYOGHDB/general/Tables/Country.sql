CREATE TABLE [general].[Country] (
    [CountryID]             INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IsActive]              BIT           NULL,
    [CountryName]           VARCHAR (100) NOT NULL,
    [FormalName]            VARCHAR (100) NULL,
    [CountryType]           VARCHAR (30)  NULL,
    [CountrySubType]        VARCHAR (100) NULL,
    [CountrySovereignty]    VARCHAR (50)  NULL,
    [CountryCapital]        VARCHAR (100) NULL,
    [ISO4217CurrencyCode]   VARCHAR (15)  NULL,
    [ISO4217CurrencyName]   VARCHAR (100) NULL,
    [ITUTTelephoneCode]     VARCHAR (50)  NULL,
    [ISO3166_1_2LetterCode] VARCHAR (2)   NULL,
    [ISO3166_1_3LetterCode] VARCHAR (3)   NULL,
    [ISO3166_1Number]       INT           NULL,
    [IANACountryCodeTLD]    VARCHAR (50)  NULL,
    CONSTRAINT [PKGeneralCountries] PRIMARY KEY CLUSTERED ([CountryID] ASC) WITH (FILLFACTOR = 90)
);

