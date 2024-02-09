CREATE TABLE [reservation].[StandardCancellationCharges] (
    [StandardCancellationChargeId] INT            IDENTITY (1, 1) NOT NULL,
    [CancellationModeId]           INT            NULL,
    [ReservationTypeId]            INT            NULL,
    [SubcategoryId]                INT            NULL,
    [CancellationPercent]          DECIMAL (5, 2) NOT NULL,
    [EffectiveFrom]                DATETIME       NOT NULL,
    [EffectiveTo]                  DATETIME       NOT NULL,
    [IsActive]                     BIT            NOT NULL,
    [CancellationDayFrom]          INT            NOT NULL,
    [CancellationDayTo]            INT            NULL,
    [NightsFrom]                   INT            NULL,
    [NightsTo]                     INT            NULL,
    CONSTRAINT [PK_StandardCancellationCharge] PRIMARY KEY CLUSTERED ([StandardCancellationChargeId] ASC) WITH (FILLFACTOR = 90)
);

