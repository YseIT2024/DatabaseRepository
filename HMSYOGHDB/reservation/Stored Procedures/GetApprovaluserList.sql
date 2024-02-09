
CREATE  Proc [reservation].[GetApprovaluserList] 

AS
Begin
  Select U.UserId, D.FirstName+' '+D.LastName AS UserName, R.RoleId, R.Role
  From   [app].[User] U 
  Join [app].[UsersAndRoles] UR ON UR.UserID= U.UserID
  Join [app].[Roles] R ON UR.RoleID= R.RoleID
  Join contact.Details D On D.ContactID=U.ContactID
End
---select * from contact.Details

