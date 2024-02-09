CREATE TABLE [Housekeeping].[LostItemEnquiry] (
    [EnquiryId]       INT            IDENTITY (1, 1) NOT NULL,
    [EnquiryType]     NCHAR (2)      NULL,
    [GuestType]       NVARCHAR (20)  NOT NULL,
    [GuestID]         INT            NOT NULL,
    [ItemType]        NVARCHAR (30)  NOT NULL,
    [ItemDescription] NVARCHAR (250) NOT NULL,
    [LostDate]        DATETIME       NOT NULL,
    [LostLocation]    NVARCHAR (50)  NOT NULL,
    [Status]          INT            NOT NULL,
    [CreatedBy]       INT            NOT NULL,
    [CreatedOn]       DATETIME       NOT NULL,
    [ModifiedBy]      INT            NULL,
    [ModifiedOn]      DATETIME       NULL,
    [IsActive]        BIT            NOT NULL,
    [FoundBy]         VARCHAR (100)  NULL,
    [StoredBy]        VARCHAR (100)  NULL,
    [ReferenceNo]     INT            NULL,
    [ReservationID]   INT            NULL,
    CONSTRAINT [PK__LostItem__0A019B7D00BF78FB] PRIMARY KEY CLUSTERED ([EnquiryId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__LostItemE__Guest__6B3AC043] FOREIGN KEY ([GuestID]) REFERENCES [guest].[Guest] ([GuestID]),
    CONSTRAINT [FK__LostItemEnquiry_Foliono] FOREIGN KEY ([ReservationID]) REFERENCES [reservation].[Reservation] ([ReservationID])
);

