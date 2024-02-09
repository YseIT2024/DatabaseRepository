-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 11-09-2023
-- Description:	GET APPROVAL History
-- =============================================
CREATE PROCEDURE [reservation].[spGetAppravalHistory] --75, 1
(
	@UserId int,
	@LocationId int
)
AS
BEGIN

	SET NOCOUNT ON;

    SELECT 
		 AL.ApprovalLogId		,AL.ProcessTypeId		,AL.LocatioId
		--,AL.CreatedOn
		,FORMAT(AL.CreatedOn, 'dd-MMM-yyyy HH:mm:ss') AS CreatedOn
		,AL.CreatedBy		,AL.ApprovalDescription		,AL.RefrenceNo
		--,AL.ApprovalStatus
		,FORMAT(AL.ModifiedOn, 'dd-MMM-yyyy HH:mm:ss') AS ModifiedOn
		--,AL.ModifiedOn
		,AL.ModifiedBy		,AL.ToRoleId		,AL.ToUserId		,AL.LogLevel		,PT.ProcessType
		,AL.Remark		,AL.OlDRate
		,AL.NewRate
		,CASE WHEN AL.ApprovalStatus=0 THEN 'Pending'
		WHEN AL.ApprovalStatus=1 THEN 'Approved'
		WHEN AL.ApprovalStatus=2 THEN 'Rejected'
		WHEN AL.ApprovalStatus=3 THEN 'Forwared'
		ELSE '' END as  ApprovalStatus
		FROM reservation.ApprovalLog AL
		INNER JOIN reservation.ProcessType PT ON AL.ProcessTypeId=PT.ProcessTypeId
		WHERE 
		 --AL.ToUserId=@UserId AND
		 AL.ModifiedBy=@UserId
		--@UserId in (select userid from reservation.ApprovalWorkflow where ProcessTypeId=al.ProcessTypeId)
		AND AL.LocatioId=@LocationId AND ApprovalStatus IN (1,2,3) 
		ORDER BY AL.ApprovalLogId DESC , AL.ProcessTypeId DESC;

END
