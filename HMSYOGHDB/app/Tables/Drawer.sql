CREATE TABLE [app].[Drawer] (
    [DrawerID]       INT          IDENTITY (1, 1) NOT NULL,
    [LocationID]     INT          NOT NULL,
    [Drawer]         VARCHAR (20) NOT NULL,
    [IsActive]       BIT          CONSTRAINT [DF_Drawer_Isactive] DEFAULT ((1)) NOT NULL,
    [MinClosingTime] TIME (7)     CONSTRAINT [DF_Drawer_MinClosingTime] DEFAULT ('23:59:00.0000000') NOT NULL,
    [MaxClosingTime] TIME (7)     CONSTRAINT [DF_Drawer_MaxClosingTime] DEFAULT ('23:59:00.0000000') NOT NULL,
    CONSTRAINT [PK_Drawer] PRIMARY KEY CLUSTERED ([DrawerID] ASC) WITH (FILLFACTOR = 90)
);

