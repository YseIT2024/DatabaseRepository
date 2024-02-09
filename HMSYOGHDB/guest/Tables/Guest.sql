CREATE TABLE [guest].[Guest] (
    [GuestID]       INT          IDENTITY (1, 1) NOT NULL,
    [ContactID]     INT          NOT NULL,
    [GroupCode]     VARCHAR (50) NULL,
    [Reference]     VARCHAR (50) NULL,
    [FoodTypeID]    INT          NULL,
    [CMSCustomerID] BIGINT       NULL,
    CONSTRAINT [PK_Guest] PRIMARY KEY CLUSTERED ([GuestID] ASC) WITH (FILLFACTOR = 90)
);

