CREATE TABLE [app].[UserDrawer] (
    [ID]        INT IDENTITY (1, 1) NOT NULL,
    [UserID]    INT NOT NULL,
    [DrawerID]  INT NOT NULL,
    [IsPrimary] BIT CONSTRAINT [DF_UserDrawer_IsPrimary] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_UserDrawer] PRIMARY KEY CLUSTERED ([ID] ASC) WITH (FILLFACTOR = 90)
);

