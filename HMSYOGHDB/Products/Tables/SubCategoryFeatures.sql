CREATE TABLE [Products].[SubCategoryFeatures] (
    [RoomTFID]      INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FeatureID]     INT           NULL,
    [SubCategoryID] INT           NULL,
    [IsListed]      BIT           NULL,
    [Remarks]       VARCHAR (200) NULL,
    [CreatedBy]     INT           NULL,
    [CreatedDate]   DATETIME      NULL,
    CONSTRAINT [PK__Room_Typ__371CACDEAEBF525F] PRIMARY KEY CLUSTERED ([RoomTFID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK__Room_Type__SC_Fe__2D27B809] FOREIGN KEY ([FeatureID]) REFERENCES [Products].[Features] ([FeatureID])
);

