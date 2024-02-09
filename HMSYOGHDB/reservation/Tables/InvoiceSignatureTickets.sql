CREATE TABLE [reservation].[InvoiceSignatureTickets] (
    [FolioNo]   INT      NULL,
    [InvoiceNo] INT      NOT NULL,
    [Status]    INT      NOT NULL,
    [CreatedOn] DATETIME NULL,
    [CreatedBy] INT      NULL,
    [UpdatedOn] DATETIME NULL,
    [UpdatedBy] INT      NULL
);

