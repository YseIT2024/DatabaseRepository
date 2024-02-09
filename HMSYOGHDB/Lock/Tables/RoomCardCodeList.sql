CREATE TABLE [Lock].[RoomCardCodeList] (
    [BuildingCode] VARCHAR (3)   NOT NULL,
    [LayerCode]    VARCHAR (3)   NOT NULL,
    [RoomCode]     VARCHAR (10)  NOT NULL,
    [SubRoomCode]  VARCHAR (3)   NOT NULL,
    [CardCode]     VARCHAR (8)   NOT NULL,
    [CardType]     TINYINT       NULL,
    [UserName]     NVARCHAR (20) NULL,
    [IDType]       NVARCHAR (20) NULL,
    [IDCode]       NVARCHAR (20) NULL,
    [IsLost]       BIT           NULL,
    [KeyCoder]     SMALLINT      NULL,
    CONSTRAINT [PK_RoomCardCodeList] PRIMARY KEY CLUSTERED ([BuildingCode] ASC, [LayerCode] ASC, [RoomCode] ASC, [SubRoomCode] ASC, [CardCode] ASC)
);

