﻿CREATE TABLE [general].[Location] (
    [LocationID]                  INT            IDENTITY (1, 1) NOT NULL,
    [LocationTypeID]              INT            NOT NULL,
    [ParentID]                    INT            NULL,
    [LocationCode]                VARCHAR (5)    NOT NULL,
    [LocationName]                VARCHAR (50)   NOT NULL,
    [CountryID]                   INT            NOT NULL,
    [MainCurrencyID]              INT            NOT NULL,
    [ReportAddress]               NVARCHAR (250) NOT NULL,
    [ReportLogo]                  VARCHAR (100)  NULL,
    [HotelCashFigureHasToBeZero]  BIT            NOT NULL,
    [AllowNegativeStock]          BIT            CONSTRAINT [DF_Location_EnableImportCustomerFromCMS] DEFAULT ((0)) NOT NULL,
    [CheckInTime]                 TIME (7)       NULL,
    [CheckOutTime]                TIME (7)       NULL,
    [IsActive]                    BIT            CONSTRAINT [DF_Location_IsActive] DEFAULT ((0)) NOT NULL,
    [Remarks]                     VARCHAR (250)  NULL,
    [RateCurrencyID]              INT            CONSTRAINT [DF__Location__RateCu__45544755] DEFAULT ((3)) NULL,
    [CasinoRateCurrencyID]        INT            NULL,
    [CasinoCashFigureHasToBeZero] BIT            NULL,
    [CommonReportLogo]            NVARCHAR (MAX) NULL,
    [AddressLine1]                VARCHAR (500)  NULL,
    [AddressLine2]                VARCHAR (500)  NULL,
    [AddressLine3]                VARCHAR (500)  NULL,
    [AddressLine4]                VARCHAR (500)  NULL,
    [AddressLine5]                VARCHAR (500)  NULL,
    [AddressLine6]                VARCHAR (500)  NULL,
    CONSTRAINT [PK_Company] PRIMARY KEY CLUSTERED ([LocationID] ASC) WITH (FILLFACTOR = 90)
);

