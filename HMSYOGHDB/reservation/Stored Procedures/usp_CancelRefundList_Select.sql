CREATE PROC [reservation].[usp_CancelRefundList_Select]
@userid int null

	
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	SELECT  rr.RefundId, rr.RefundDate,rr.TransactionModeID,rr.RefundAmount, rr.CancellationID,rr.CancellationDate,rr.CreatedOn,rr.CreatedBy,rr.CancellationMode,
			rr.ReservationId,rr.GuestId,rr.GuestName,rr.[Address],atr.[TransactionMode]
			FROM [reservation].[Refund] rr
			INNER JOIN [account].[TransactionMode] atr ON rr.TransactionModeID=atr.TransactionModeID
END