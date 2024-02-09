CREATE TABLE [reservation].[PenaltyCharges] (
    [TimeId]              INT             NOT NULL,
    [SubcategoryId]       INT             NOT NULL,
    [EarlyCheckInCharges] DECIMAL (18, 2) NOT NULL,
    [LateCheckOutCharges] DECIMAL (18, 2) NOT NULL,
    [ModifiedBy]          INT             NOT NULL,
    [ModifiedOn]          DATETIME        NOT NULL,
    CONSTRAINT [PK_PenaltyCharges] PRIMARY KEY CLUSTERED ([TimeId] ASC, [SubcategoryId] ASC)
);

