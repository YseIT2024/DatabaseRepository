CREATE TABLE [general].[Company] (
    [CompanyID]   INT           IDENTITY (1, 1) NOT NULL,
    [CompanyName] VARCHAR (100) NOT NULL,
    [CompanyType] VARCHAR (50)  NOT NULL,
    [Address]     VARCHAR (100) NOT NULL,
    [PhoneNumber] VARCHAR (50)  NOT NULL,
    [ContactID]   INT           NULL,
    CONSTRAINT [PK_Company_1] PRIMARY KEY CLUSTERED ([CompanyID] ASC) WITH (FILLFACTOR = 90)
);

