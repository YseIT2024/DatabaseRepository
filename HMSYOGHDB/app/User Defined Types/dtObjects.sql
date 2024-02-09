CREATE TYPE [app].[dtObjects] AS TABLE (
    [ID]                  INT           NOT NULL,
    [ObjectName]          VARCHAR (50)  NOT NULL,
    [DisplayText]         VARCHAR (50)  NOT NULL,
    [ObjectPath]          VARCHAR (250) NOT NULL,
    [Tab]                 VARCHAR (50)  NOT NULL,
    [TabDisplayText]      VARCHAR (50)  NOT NULL,
    [TabGroup]            VARCHAR (50)  NOT NULL,
    [TabGroupDisplayText] VARCHAR (50)  NOT NULL);

