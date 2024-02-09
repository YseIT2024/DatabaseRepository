CREATE TABLE [Products].[RoomTypePaxLimit] (
    [SubCategoryID]           INT      NOT NULL,
    [MaxAdult]                INT      NOT NULL,
    [MaxChild]                INT      NOT NULL,
    [AddMaxAdult]             INT      NOT NULL,
    [AddAdultRateInPercent]   INT      NULL,
    [AddMaxChildJr]           INT      NOT NULL,
    [AddChildJrRateInPercent] INT      NULL,
    [AddMaxChildSr]           INT      NOT NULL,
    [AddChildSrRateInPercent] INT      NULL,
    [CreatedBy]               INT      NOT NULL,
    [CreateDate]              DATETIME NOT NULL,
    [IsActive]                BIT      NOT NULL,
    CONSTRAINT [PK__RoomType__26BE5BF9B90CDEF6] PRIMARY KEY CLUSTERED ([SubCategoryID] ASC) WITH (FILLFACTOR = 90)
);

