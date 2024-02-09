CREATE TABLE [shift].[Shift] (
    [ShiftID]      INT          IDENTITY (1, 1) NOT NULL,
    [Shift]        VARCHAR (50) NOT NULL,
    [StartAt]      TIME (7)     NULL,
    [EndAt]        TIME (7)     NULL,
    [MinMinutes]   INT          NULL,
    [IsActive]     BIT          CONSTRAINT [DF_Shift_IsActive] DEFAULT ((1)) NOT NULL,
    [DisplayOrder] INT          CONSTRAINT [DF_Shift_DisplayOrder] DEFAULT ((0)) NOT NULL,
    [ShowInUI]     BIT          CONSTRAINT [DF_Shift_ShowInUI] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Shift_1] PRIMARY KEY CLUSTERED ([ShiftID] ASC) WITH (FILLFACTOR = 90)
);

