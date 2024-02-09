-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 26-09-2023
-- Description:	GET APPROVAL VALIDATION 
-- =============================================
CREATE PROCEDURE [reservation].[spGetReservationAdvancePaymentApprovalValidation]
(
		@RefrenceNo int,
		@LocationID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT ISNULL(AuthorizedFlag,0) AS AuthorizedFlag FROM reservation.Reservation WHERE ReservationID=@RefrenceNo 
	 
END


--select 
--	 ApprovalStatus as ApprovalStatusId,
--	 CASE 
--	 WHEN ApprovalStatus=0 THEN 'Pending'
--	 WHEN ApprovalStatus=1 THEN 'Approved'
--	 WHEN ApprovalStatus=2 THEN 'Rejected'  
--	 WHEN ApprovalStatus=3 THEN 'Forwarded'  
--	 ELSE '' END  as ApprovalStatus
--	 from [reservation].[ApprovalLog] WHERE RefrenceNo=@RefrenceNo AND LocatioId=@LocationID
--	 and ApprovalLogId=(select top(1) ApprovalLogId from [reservation].[ApprovalLog] WHERE RefrenceNo=@RefrenceNo AND LocatioId=@LocationID order by ApprovalLogId desc)