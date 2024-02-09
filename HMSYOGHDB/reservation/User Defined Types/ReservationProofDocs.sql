CREATE TYPE [reservation].[ReservationProofDocs] AS TABLE (
    [ReservationID]  INT           NULL,
    [GuestMatesID]   INT           NULL,
    [DocumentTypeId] INT           NULL,
    [DocumentURL]    VARCHAR (250) NULL);

