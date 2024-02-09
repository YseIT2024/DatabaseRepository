CREATE TABLE [Products].[SubCategory] (
    [SubCategoryID]            INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CategoryID]               INT           NOT NULL,
    [Code]                     VARCHAR (50)  NOT NULL,
    [Name]                     VARCHAR (100) NOT NULL,
    [Description]              VARCHAR (500) NULL,
    [Remarks]                  VARCHAR (200) NULL,
    [MaxReservingCapacity]     INT           NULL,
    [MaxChildAge]              INT           NULL,
    [CreatedBy]                INT           NOT NULL,
    [CreateDate]               DATETIME      NOT NULL,
    [IsActive]                 BIT           NULL,
    [TotalInventory]           INT           NULL,
    [Online_Listing]           INT           NULL,
    [MaxAdditionalBedCapacity] INT           NULL,
    [MaxAdultsCapacity]        INT           NULL,
    [MaxChildrensCapacity]     INT           NULL,
    [EffectiveFrom]            DATETIME      NULL,
    [EffectiveTo]              DATETIME      NULL,
    [AcceptOnlineReservations] TINYINT       NULL,
    CONSTRAINT [PK__Sub_Cate__26BE5BF9A6B7E556] PRIMARY KEY CLUSTERED ([SubCategoryID] ASC) WITH (FILLFACTOR = 90)
);

