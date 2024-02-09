CREATE TABLE [app].[Parameter] (
    [ParameterID] INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [Value]       VARCHAR (100) NOT NULL,
    [Parameter]   VARCHAR (50)  NULL
);

