CREATE PROC [service].[uspTypeDelete]
@ServiceTypeID int
AS 
    SET NOCOUNT ON
    SET XACT_ABORT ON

    BEGIN TRAN

    DELETE
    FROM   service.Type
    WHERE  ServiceTypeID = @ServiceTypeID

    COMMIT
