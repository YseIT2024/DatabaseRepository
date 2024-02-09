CREATE PROC [guest].[usp_GuestLuggage_Update]
@LuggageTagID int,
@GuestID int,
@ReservationID int,
@FolioNo int,
@BellboyId int,
@LuggageNo int,
@LuggageType varchar(50),
@TagDescription varchar(max),
@TagQRCode varchar(500),
@TagPrintingStatus varchar(50),
@IsActive bit,
@CreatedBy int,
@CreatedOn datetime
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    UPDATE guest.GuestLuggage
    SET    GuestID = @GuestID, ReservationID = @ReservationID, FolioNo = @FolioNo, BellboyId = @BellboyId, 
           LuggageNo = @LuggageNo, LuggageType = @LuggageType, TagDescription = @TagDescription, TagQRCode = @TagQRCode, 
           TagPrintingStatus = @TagPrintingStatus, IsActive = @IsActive, CreatedBy = @CreatedBy, CreatedOn = @CreatedOn
    WHERE  LuggageTagID = @LuggageTagID

    /*
    -- Begin Return row code block

    SELECT GuestID, ReservationID, FolioNo, BellboyId, LuggageNo, LuggageType, TagDescription, TagQRCode, 
           TagPrintingStatus, IsActive, CreatedBy, CreatedOn
    FROM   guest.GuestLuggage
    WHERE  LuggageTagID = @LuggageTagID

    -- End Return row code block

    */
    COMMIT
