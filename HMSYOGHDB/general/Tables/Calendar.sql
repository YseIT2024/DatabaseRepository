CREATE TABLE [general].[Calendar] (
    [date_id]            DATE         NOT NULL,
    [date_year]          SMALLINT     NOT NULL,
    [date_month]         TINYINT      NOT NULL,
    [date_day]           TINYINT      NOT NULL,
    [weekday_id]         TINYINT      NOT NULL,
    [weekday_nm]         VARCHAR (10) NOT NULL,
    [month_nm]           VARCHAR (10) NOT NULL,
    [day_of_year]        SMALLINT     NOT NULL,
    [quarter_id]         TINYINT      NOT NULL,
    [first_day_of_month] DATE         NOT NULL,
    [last_day_of_month]  DATE         NOT NULL,
    [start_dts]          DATETIME     NOT NULL,
    [end_dts]            DATETIME     NOT NULL,
    CONSTRAINT [PK_Calendar] PRIMARY KEY CLUSTERED ([date_id] ASC) WITH (FILLFACTOR = 90)
);

