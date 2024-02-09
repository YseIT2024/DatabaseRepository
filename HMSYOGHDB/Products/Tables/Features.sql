CREATE TABLE [Products].[Features] (
    [FeatureID]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CategoryID]  INT           NOT NULL,
    [Name]        VARCHAR (100) NOT NULL,
    [Group]       VARCHAR (50)  NULL,
    [Remarks]     VARCHAR (200) NULL,
    [IsPrimary]   BIT           NULL,
    [IsActive]    BIT           NOT NULL,
    [CreatedBy]   INT           NULL,
    [CreateDate]  DATETIME      NULL,
    [FeatureIcon] NCHAR (50)    NULL,
    CONSTRAINT [PK__Sub_Cate__C68E0265C2E258CA] PRIMARY KEY CLUSTERED ([FeatureID] ASC) WITH (FILLFACTOR = 90)
);

