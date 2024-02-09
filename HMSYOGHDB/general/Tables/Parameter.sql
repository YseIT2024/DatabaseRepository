CREATE TABLE [general].[Parameter] (
    [ParameterId]    INT           NOT NULL,
    [ParameterName]  VARCHAR (250) NOT NULL,
    [ParameterValue] VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Parameter] PRIMARY KEY CLUSTERED ([ParameterId] ASC)
);

