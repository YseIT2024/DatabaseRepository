
-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 11-09-2023
-- Description:	GET APPROVAL LIST LOG AND APPROVAL USER
-- =============================================
CREATE PROCEDURE [reservation].[spGetAppravalLogList]
(
	@RefrenceNo int,
	@ProcessTypeId int
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
		,AL.RefrenceNo,
		CASE
		WHEN AL.ApprovalStatus=0 THEN 'Pending'
		WHEN AL.ApprovalStatus=1 THEN 'Approved'
		WHEN AL.ApprovalStatus=2 THEN 'Rejected'
		WHEN AL.ApprovalStatus=3 THEN 'Forward'
		ELSE
		''
		End AS ApprovalStatus
		,AL.ModifiedOn
		,AL.ModifiedBy
		,AL.ToRoleId
		,AL.ToUserId
		,AL.LogLevel
		,PT.ProcessType
		,CONCAT(CD.FirstName , CD.LastName) AS ToUserName
		,CONCAT(CD1.FirstName , CD1.LastName) AS CreatedUserName
		,AL.Remark
		FROM reservation.ApprovalLog AL
		INNER JOIN reservation.ProcessType PT ON AL.ProcessTypeId=PT.ProcessTypeId
		INNER JOIN app.[User] U on AL.ToUserId=U.UserID
		INNER JOIN contact.Details CD on U.ContactID=CD.ContactID
		INNER JOIN app.[User] U1 on AL.CreatedBy=U1.UserID
		INNER JOIN contact.Details CD1 on U1.ContactID=CD1.ContactID
		WHERE AL.RefrenceNo=@RefrenceNo
		ORDER BY AL.CreatedOn DESC


		SELECT U.UserID, CONCAT(CD.FirstName,CD.LastName) AS Username 
		FROM [reservation].[ApprovalWorkflow] AEF
		INNER JOIN   app.[User] U on AEF.UserId=U.UserID
		INNER JOIN contact.Details CD on U.ContactID=CD.ContactID
		WHERE AEF.ProcessTypeId=@ProcessTypeId 
		--AND AEF.ApprovalLevel>(SELECT TOP(1)  ISNULL(LogLevel,0) FROM reservation.ApprovalLog where ProcesstypeId=@ProcessTypeId order by ApprovalLogId desc)
END

 
