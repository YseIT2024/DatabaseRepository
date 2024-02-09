-- =============================================
-- Author:		VASANTHAKUMAR R
-- Create date: 11-09-2023
-- Description:	GET APPROVAL LOG USER
-- =============================================
Create PROCEDURE [reservation].[spGetAppravalLogUser]
(
	@ProcessTypeId int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT U.UserID, CONCAT(CD.FirstName,CD.LastName) AS Username 
		FROM [reservation].[ApprovalWorkflow] AEF
		INNER JOIN   app.[User] U on AEF.UserId=U.UserID
		INNER JOIN contact.Details CD on U.ContactID=CD.ContactID
		WHERE AEF.ProcessTypeId=@ProcessTypeId

END
