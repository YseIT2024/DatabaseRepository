CREATE TABLE [reservation].[ReservationServices] (
    [TransId]         INT             IDENTITY (1, 1) NOT NULL,
    [ReservationID]   INT             NOT NULL,
    [ServiceId]       INT             NOT NULL,
    [ServiceDate]     DATETIME        NOT NULL,
    [ServiceQty]      INT             NOT NULL,
    [GuestQty]        INT             NOT NULL,
    [ServiceTimeId]   INT             NULL,
    [ServiceType]     INT             NOT NULL,
    [Status]          VARCHAR (6)     NOT NULL,
    [ServiceRate]     DECIMAL (18)    NULL,
    [UserID]          INT             NOT NULL,
    [DateTime]        DATETIME        NOT NULL,
    [IsActive]        INT             NOT NULL,
    [LocationId]      INT             NULL,
    [RoomId]          INT             NULL,
    [LocationName]    NCHAR (100)     NULL,
    [RoomDescription] NVARCHAR (100)  NULL,
    [RoomService]     INT             NULL,
    [Amount]          DECIMAL (18, 3) NULL,
    CONSTRAINT [PK_ReservationServices] PRIMARY KEY CLUSTERED ([TransId] ASC) WITH (FILLFACTOR = 90)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 is default and 1 for room service', @level0type = N'SCHEMA', @level0name = N'reservation', @level1type = N'TABLE', @level1name = N'ReservationServices', @level2type = N'COLUMN', @level2name = N'RoomService';

