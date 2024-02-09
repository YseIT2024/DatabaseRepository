

CREATE PROCEDURE [reservation].[spGetAppravalList] --85,1
(
	@UserId int,
	@LocationId int
)
AS
BEGIN

	SET NOCOUNT ON;
	 

    SELECT 
		 AL.ApprovalLogId
		,AL.ProcessTypeId
		,AL.LocatioId
		,AL.CreatedOn
		,AL.CreatedBy
		,AL.ApprovalDescription
		,AL.RefrenceNo
		,AL.ApprovalStatus
		,AL.ModifiedOn
		,AL.ModifiedBy
		,AL.ToRoleId
		,AL.ToUserId
		,AL.LogLevel
		,PT.ProcessType
		,AL.Remark
		,AL.OlDRate
		,AL.NewRate
		FROM reservation.ApprovalLog AL
		INNER JOIN reservation.ProcessType PT ON AL.ProcessTypeId=PT.ProcessTypeId
		WHERE  AL.LocatioId=@LocationId AND ApprovalStatus IN (0) AND AL.IsApprovalVisible=1 
		AND  @UserId in (select userid from reservation.ApprovalWorkflow where ProcessTypeId=al.ProcessTypeId)
		ORDER BY AL.ApprovalLogId DESC
		

END