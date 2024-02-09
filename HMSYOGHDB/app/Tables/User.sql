CREATE TABLE [app].[User] (
    [UserID]             INT            IDENTITY (1, 1) NOT NULL,
    [UserName]           VARCHAR (50)   NOT NULL,
    [Password]           VARCHAR (30)   NOT NULL,
    [ContactID]          INT            NOT NULL,
    [IsActive]           BIT            CONSTRAINT [DF_User_IsActive] DEFAULT ((1)) NOT NULL,
    [ApplicationModeID]  INT            CONSTRAINT [DF_User_ApplicationModeID] DEFAULT ((1)) NOT NULL,
    [IsPOSUser]          BIT            NULL,
    [TokenKey]           VARCHAR (100)  NULL,
    [TokenExpiry]        DATETIME       NULL,
    [MachineID]          VARCHAR (50)   NULL,
    [MaxDiscountPercent] DECIMAL (8, 2) NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [UC_User] UNIQUE NONCLUSTERED ([UserName] ASC) WITH (FILLFACTOR = 90)
);

