CREATE TABLE [Products].[CategoryFilters] (
    [FilterID]     INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CategoryID]   INT NULL,
    [IsRoom]       BIT NULL,
    [IsFood]       BIT NULL,
    [IsBeverage]   BIT NULL,
    [IsSpa]        BIT NULL,
    [IsPool]       BIT NULL,
    [IsMeeting]    BIT NULL,
    [IsInventory]  BIT NULL,
    [IsBoutique]   BIT NULL,
    [IsAmenities]  BIT NULL,
    [IsFacilities] BIT NULL,
    [IsRestaurant] BIT NULL,
    [IsOthers]     BIT NULL,
    CONSTRAINT [PK__Category__CD5DA43CAE153C98] PRIMARY KEY CLUSTERED ([FilterID] ASC) WITH (FILLFACTOR = 90)
);

