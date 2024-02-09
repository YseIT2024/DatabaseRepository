CREATE Proc [guest].[usp_GuestLuggage_Insert]
	--Add new parameters at the end. Dont change the sequence
	@ReservationID int,
	@BellboyId int,
	@CreatedBy int,
	@IsActive bit,
	@GuestID int, 
	@ReservationStatusID int,
	@TagQRCode varchar(500) = null,
    @LuggageTagID int = null,      
    @FolioNo int = null,    
    @LuggageNo int = null,
    @LuggageType varchar(50) = null,
    @TagDescription varchar(max) = null,    
    @TagPrintingStatus varchar(50) = null
    
   
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    INSERT INTO guest.GuestLuggage (GuestID, ReservationID, FolioNo, BellboyId, LuggageNo, 
                                    LuggageType, TagDescription, TagQRCode, TagPrintingStatus, IsActive, 
                                    CreatedBy, CreatedOn, ReservationStatusID)
    SELECT  @GuestID, @ReservationID, @FolioNo, @BellboyId, @LuggageNo, @LuggageType, 
           @TagDescription, @TagQRCode, @TagPrintingStatus, @IsActive, @CreatedBy, GETDATE(), @ReservationStatusID

    /*
    -- Begin Return row code block

    SELECT LuggageTagID, GuestID, ReservationID, FolioNo, BellboyId, LuggageNo, LuggageType, TagDescription, 
           TagQRCode, TagPrintingStatus, IsActive, CreatedBy, CreatedOn
    FROM   guest.GuestLuggage
    WHERE  LuggageTagID = @LuggageTagID AND GuestID = @GuestID AND ReservationID = @ReservationID AND 
           FolioNo = @FolioNo AND BellboyId = @BellboyId AND LuggageNo = @LuggageNo AND LuggageType = @LuggageType AND 
           TagDescription = @TagDescription AND TagQRCode = @TagQRCode AND TagPrintingStatus = @TagPrintingStatus AND 
           IsActive = @IsActive AND CreatedBy = @CreatedBy AND CreatedOn = @CreatedOn

    -- End Return row code block

    */
    COMMIT
