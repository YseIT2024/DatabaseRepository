CREATE TABLE [guest].[OTAServices] (
    [ReservationServiceId] INT             IDENTITY (1, 1) NOT NULL,
    [ReservationID]        INT             NOT NULL,
    [GuestID_CompanyID]    INT             NOT NULL,
    [ServiceID]            INT             NOT NULL,
    [ServicePercent]       DECIMAL (18, 6) NULL,
    [ReservationTypeID]    INT             NULL,
    [Type]                 NVARCHAR (50)   NULL,
    CONSTRAINT [PK_ReservationServiceId] PRIMARY KEY CLUSTERED ([ReservationServiceId] ASC) WITH (FILLFACTOR = 90)
);

