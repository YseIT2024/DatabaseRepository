CREATE TYPE [reservation].[dtReservationGuestInfos] AS TABLE (
    [reservation_ID] INT           NULL,
    [guest_ID]       INT           NULL,
    [guestName]      VARCHAR (100) NULL,
    [age]            INT           NULL,
    [dob]            DATE          NULL,
    [is_Kid]         CHAR (1)      NULL,
    [nationality]    VARCHAR (100) NULL,
    [remarks]        VARCHAR (100) NULL,
    [guest_Attach]   VARCHAR (MAX) NULL);

