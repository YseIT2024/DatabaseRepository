CREATE PROC [guest].[usp_GuestLuggage_Delete]
@LuggageTagID int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   guest.GuestLuggage
    WHERE  LuggageTagID = @LuggageTagID

    COMMIT
