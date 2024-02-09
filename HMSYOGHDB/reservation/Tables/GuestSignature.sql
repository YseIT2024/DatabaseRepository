CREATE TABLE [reservation].[GuestSignature] (
    [GuestSignatureID]     INT            IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]            INT            NULL,
    [GuestSignature]       NVARCHAR (MAX) NULL,
    [ManagerSignature]     NVARCHAR (MAX) NULL,
    [GuestName]            NVARCHAR (150) NULL,
    [GuestID]              INT            NULL,
    [IsActive]             INT            CONSTRAINT [DF_GuestSignature_IsActive] DEFAULT ((1)) NULL,
    [DateTime]             DATETIME       NULL,
    [ModifiedDateTime]     DATETIME       NULL,
    [GuestSignatureTypeID] INT            NULL,
    CONSTRAINT [PK_GuestSignature] PRIMARY KEY CLUSTERED ([GuestSignatureID] ASC) WITH (FILLFACTOR = 90)
);

