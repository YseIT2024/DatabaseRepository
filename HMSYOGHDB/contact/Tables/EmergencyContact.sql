CREATE TABLE [contact].[EmergencyContact] (
    [EmrContactID]       INT           IDENTITY (1, 1) NOT NULL,
    [ReservationID]      INT           NOT NULL,
    [EmrContactName]     VARCHAR (100) NOT NULL,
    [EmrContactNumber]   VARCHAR (15)  NOT NULL,
    [EmrContactRelation] VARCHAR (150) NULL,
    [CreatedBy]          INT           NOT NULL,
    [CreatedDate]        DATETIME      NOT NULL,
    [IsActive]           BIT           NOT NULL,
    CONSTRAINT [PK_EmergencyContact] PRIMARY KEY CLUSTERED ([EmrContactID] ASC) WITH (FILLFACTOR = 90)
);

