CREATE TABLE [Housekeeping].[LostItemDispatchDetails] (
    [DispatchId]     INT            IDENTITY (1, 1) NOT NULL,
    [EnquiryId]      INT            NULL,
    [DisposalStatus] INT            NULL,
    [DisposeMode]    INT            NULL,
    [DisposeDate]    DATETIME       NULL,
    [DisposeTo]      NVARCHAR (30)  NULL,
    [DispatchBy]     NVARCHAR (30)  NULL,
    [Remarks]        NVARCHAR (250) NULL,
    [CreatedBy]      INT            NOT NULL,
    [CreatedOn]      DATETIME       NOT NULL,
    [ModifiedBy]     INT            NULL,
    [ModifiedOn]     DATETIME       NULL,
    [IsActive]       BIT            NOT NULL,
    [LocationId]     INT            NULL,
    CONSTRAINT [PK__LostItem__FBDF78E97D03EE34] PRIMARY KEY CLUSTERED ([DispatchId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__LostItemF__Enqui__6FFF7560] FOREIGN KEY ([EnquiryId]) REFERENCES [Housekeeping].[LostItemEnquiry] ([EnquiryId])
);

