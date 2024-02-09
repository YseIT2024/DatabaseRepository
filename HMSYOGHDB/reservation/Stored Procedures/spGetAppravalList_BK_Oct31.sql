Create PROCEDURE [reservation].[spGetAppravalList_BK_Oct31]
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
		WHERE AL.ToUserId=@UserId AND AL.LocatioId=@LocationId AND ApprovalStatus IN (0);

END
