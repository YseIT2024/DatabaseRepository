CREATE Proc [reservation].[GetApprovalWorkflow]

AS
Begin
    Select AWF.ApprovalWorkflowId,AWF.ProcessTypeId,  AWF.ApprovalLevel, AWF.UserId , AWF.RoleId , 
	AWF.IsActive , AWF.IsPrimary , PT.*, R.Role, 
	--Cast(U.UserName AS int) As [UID], 
	AWF.UserId as [UID],
	D.FirstName+' '+ D.LastName AS UserName
    From [reservation].[ApprovalWorkflow] AWF
    Full join [reservation].[ProcessType] PT ON PT.ProcessTypeId= AWF.ProcessTypeId
    Left Join [app].[Roles] R ON R.RoleId= AWF.RoleId	
	Left Join [app].[User] U ON U.UserID = AWF.UserId
	left Join contact.Details D On D.ContactID=U.ContactID

	Order By  AWF.ProcessTypeId ASC, AWF.ApprovalLevel ASC, AWF.IsPrimary DESC
End

