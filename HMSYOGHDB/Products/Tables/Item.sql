﻿CREATE TABLE [Products].[Item] (
    [ItemID]          INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ItemCode]        VARCHAR (50)    NOT NULL,
    [ItemName]        VARCHAR (255)   NOT NULL,
    [CategoryID]      INT             NOT NULL,
    [SubCategoryID]   INT             NOT NULL,
    [BrandID]         INT             NULL,
    [ItemTypeID]      INT             NOT NULL,
    [CuisineTypeID]   INT             NULL,
    [GroupID]         INT             NULL,
    [UOMID]           INT             NOT NULL,
    [Price]           DECIMAL (18, 4) NULL,
    [CurrencyId]      INT             NULL,
    [MaxDiscount]     DECIMAL (12, 2) CONSTRAINT [DF_Item_MaxDiscount] DEFAULT ((0)) NULL,
    [ReorderLevel]    INT             NULL,
    [BarcodeValue]    VARCHAR (50)    NULL,
    [Remarks]         VARCHAR (255)   NULL,
    [IsActive]        BIT             NOT NULL,
    [IsListed]        BIT             NULL,
    [CreatedBy]       INT             NULL,
    [CreateDate]      DATETIME        NULL,
    [Price_Type]      VARCHAR (10)    NULL,
    [Tax_Included]    VARCHAR (1)     CONSTRAINT [DF_Item_Tax_Included] DEFAULT ('Y') NULL,
    [ItemDisplayName] VARCHAR (250)   NULL,
    CONSTRAINT [PK__Item__3FB50F940B31FCC7] PRIMARY KEY CLUSTERED ([ItemID] ASC) WITH (FILLFACTOR = 90)
);
