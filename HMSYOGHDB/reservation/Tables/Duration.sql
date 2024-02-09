CREATE TABLE [reservation].[Duration] (
    [DurationID]  INT          IDENTITY (1, 1) NOT NULL,
    [Duration]    VARCHAR (15) NOT NULL,
    [DisplayText] VARCHAR (10) NOT NULL,
    CONSTRAINT [PK_Duration] PRIMARY KEY CLUSTERED ([DurationID] ASC) WITH (FILLFACTOR = 90)
);

