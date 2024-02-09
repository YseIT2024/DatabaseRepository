CREATE TABLE [contact].[Details] (
    [ContactID]       INT           IDENTITY (1, 1) NOT NULL,
    [TitleID]         INT           NULL,
    [FirstName]       VARCHAR (100) NOT NULL,
    [LastName]        VARCHAR (100) NULL,
    [GenderID]        INT           NULL,
    [DOB]             DATE          NULL,
    [MaritalStatusID] INT           NULL,
    [LanguageID]      INT           NULL,
    [OccupationID]    INT           NULL,
    [IDCardTypeID]    INT           NULL,
    [DepartmentID]    INT           NULL,
    [DesignationID]   INT           NULL,
    [IDCardNumber]    VARCHAR (30)  NULL,
    [ImageID]         INT           NULL,
    CONSTRAINT [PK_Details] PRIMARY KEY CLUSTERED ([ContactID] ASC) WITH (FILLFACTOR = 90)
);

