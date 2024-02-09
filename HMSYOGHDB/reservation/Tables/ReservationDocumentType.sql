CREATE TABLE [reservation].[ReservationDocumentType] (
    [DocumentTypeId] INT           IDENTITY (1, 1) NOT NULL,
    [DocumentType]   VARCHAR (100) NOT NULL,
    [IsMandatory]    INT           NOT NULL,
    [CreatedBy]      INT           NOT NULL,
    [CreatedOn]      DATETIME      NOT NULL,
    [IsActive]       BIT           NOT NULL
);

