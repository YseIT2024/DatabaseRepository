CREATE TYPE [guest].[OTAServicesType] AS TABLE (
    [ReservationID]     INT             NULL,
    [GuestID]           INT             NULL,
    [ServiceID]         INT             NULL,
    [SericePercent]     DECIMAL (18, 6) NULL,
    [ReservationTypeID] INT             NULL,
    [Type]              NVARCHAR (50)   NULL);

