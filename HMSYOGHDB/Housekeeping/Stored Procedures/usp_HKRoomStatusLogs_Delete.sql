CREATE PROC [Housekeeping].[usp_HKRoomStatusLogs_Delete]
@HKStatusLogID bigint
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   Housekeeping.HKRoomStatusLogs
    WHERE  HKStatusLogID = @HKStatusLogID

    COMMIT
