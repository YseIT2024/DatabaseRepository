CREATE TABLE [Products].[BlockedRoom] (
    [BlockedId]   INT          IDENTITY (1, 1) NOT NULL,
    [RoomID]      INT          NOT NULL,
    [FromDate]    DATETIME     NOT NULL,
    [ToDate]      DATETIME     NOT NULL,
    [blockTypeId] INT          NOT NULL,
    [Status]      VARCHAR (50) NULL,
    [IsActive]    BIT          NULL,
    [CreatedBy]   INT          NOT NULL,
    [CreatedOn]   DATETIME     NOT NULL,
    [ModifiedBy]  INT          NULL,
    [ModifiedOn]  DATETIME     NULL,
    [Remarks]     VARCHAR (50) NULL,
    CONSTRAINT [PK_HKChecklist] PRIMARY KEY CLUSTERED ([BlockedId] ASC) WITH (FILLFACTOR = 90)
);

