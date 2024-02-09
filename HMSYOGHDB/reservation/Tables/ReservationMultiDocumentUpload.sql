CREATE TABLE [reservation].[ReservationMultiDocumentUpload] (
    [MultiDocumentID] INT            IDENTITY (1, 1) NOT NULL,
    [DocumentId]      INT            NOT NULL,
    [ReservationID]   INT            NOT NULL,
    [GuestMatesID]    INT            NOT NULL,
    [CreatedBy]       INT            NOT NULL,
    [CreatedOn]       DATETIME       NOT NULL,
    [IsActive]        BIT            NOT NULL,
    [DocumentTypeId]  INT            NOT NULL,
    [DocumentURL]     VARCHAR (250)  NULL,
    [DocumentImage]   NVARCHAR (MAX) NULL,
    [DocumentContent] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([MultiDocumentID] ASC)
);

