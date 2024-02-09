CREATE TABLE [guest].[GuestLuggage] (
    [LuggageTagID]        INT           IDENTITY (1, 1) NOT NULL,
    [GuestID]             INT           NULL,
    [ReservationID]       INT           NOT NULL,
    [FolioNo]             INT           NULL,
    [BellboyId]           INT           NOT NULL,
    [LuggageNo]           INT           NULL,
    [LuggageType]         VARCHAR (50)  NULL,
    [TagDescription]      VARCHAR (MAX) NULL,
    [TagQRCode]           VARCHAR (500) NULL,
    [TagPrintingStatus]   VARCHAR (50)  NULL,
    [IsActive]            BIT           NOT NULL,
    [ReservationStatusID] INT           NULL,
    [CreatedBy]           INT           NOT NULL,
    [CreatedOn]           DATETIME      NOT NULL,
    CONSTRAINT [PK_GuestLuggage] PRIMARY KEY CLUSTERED ([LuggageTagID] ASC) WITH (FILLFACTOR = 90)
);

