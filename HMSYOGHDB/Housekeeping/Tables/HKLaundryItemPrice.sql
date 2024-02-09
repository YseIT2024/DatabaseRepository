CREATE TABLE [Housekeeping].[HKLaundryItemPrice] (
    [LaundryItemPriceID]   INT             IDENTITY (1, 1) NOT NULL,
    [ItemID]               INT             NOT NULL,
    [ItemRateCleaning]     DECIMAL (18, 2) NOT NULL,
    [ItemRateDryCleaning]  DECIMAL (18, 2) NOT NULL,
    [ItemRatePress]        DECIMAL (18, 2) NOT NULL,
    [ItemRateRepair]       DECIMAL (18, 2) NOT NULL,
    [ExpressServiceCharge] DECIMAL (18, 2) NOT NULL,
    [ValidFrom]            DATETIME        NOT NULL,
    [ValidTo]              DATETIME        NOT NULL,
    [IsActive]             BIT             NOT NULL,
    [CreatedBy]            INT             NOT NULL,
    [CreatedOn]            DATETIME        NOT NULL,
    [ModifiedBy]           INT             NULL,
    [ModifiedOn]           DATETIME        NULL,
    [LocationId]           INT             NULL,
    [ItemRateChild]        DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_LaundryItemPrice] PRIMARY KEY CLUSTERED ([LaundryItemPriceID] ASC) WITH (FILLFACTOR = 90)
);

