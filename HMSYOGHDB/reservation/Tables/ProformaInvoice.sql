CREATE TABLE [reservation].[ProformaInvoice] (
    [ProformaInvoiceId] INT            IDENTITY (1, 1) NOT NULL,
    [ReservationId]     INT            NULL,
    [ProformaInvoiceNo] NVARCHAR (250) NULL,
    [CreatedDate]       DATETIME       NULL,
    [CreatedBy]         INT            NULL,
    [DocumentTypeId]    INT            NULL,
    [Guest_CompanyId]   INT            NULL,
    [Type]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_reservation.ProformaInvoice] PRIMARY KEY CLUSTERED ([ProformaInvoiceId] ASC) WITH (FILLFACTOR = 90)
);

