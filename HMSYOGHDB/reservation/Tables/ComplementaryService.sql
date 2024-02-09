CREATE TABLE [reservation].[ComplementaryService] (
    [ComplementaryServiceId] INT      IDENTITY (1, 1) NOT NULL,
    [FolioNo]                INT      NOT NULL,
    [LedgerId]               INT      NOT NULL,
    [ServiceId]              INT      NOT NULL,
    [IsActive]               BIT      NULL,
    [CreatedBy]              INT      NOT NULL,
    [CreatedOn]              DATETIME NOT NULL,
    [ModifiedBy]             INT      NULL,
    [ModifiedOn]             DATETIME NULL,
    CONSTRAINT [PK_ComplementaryServiceId] PRIMARY KEY CLUSTERED ([ComplementaryServiceId] ASC) WITH (FILLFACTOR = 90)
);

