CREATE TABLE [reservation].[ReservationGuestMates] (
    [GuestMatesID]     INT           IDENTITY (1, 1) NOT NULL,
    [ReservationID]    INT           NOT NULL,
    [FirstName]        VARCHAR (100) NOT NULL,
    [MiddleName]       VARCHAR (100) NULL,
    [LastName]         VARCHAR (100) NULL,
    [Gender]           INT           NOT NULL,
    [DOB]              DATETIME      NULL,
    [GuestType]        INT           NOT NULL,
    [Nationality]      INT           NOT NULL,
    [PIDType]          INT           NULL,
    [PIDNo]            VARCHAR (50)  NULL,
    [ActualCheckIn]    DATETIME      NULL,
    [ExpectedCheckOut] DATETIME      NULL,
    [ActualCheckOut]   DATETIME      NULL,
    [UserID]           INT           NOT NULL,
    [CreatedDate]      DATETIME      NOT NULL,
    [IsActive]         INT           NOT NULL,
    [GuestID]          INT           NULL,
    [RoomID]           INT           NULL,
    CONSTRAINT [PK_ReservationGuestMates] PRIMARY KEY CLUSTERED ([GuestMatesID] ASC) WITH (FILLFACTOR = 90)
);

