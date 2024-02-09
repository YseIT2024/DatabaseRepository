CREATE proc [Products].[ApproveOrRejectAllRoomPrice]
@UserId int,
@ApprovalStatus tinyint
as
Begin
declare @IsSuccess int=0;
Declare @Message VArchar(200);
Declare @UserName varchar(100);
Set @UserName=(
    SELECT TL.[Title] + ' ' + CD.[FirstName] + 
    (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
    FROM app.[User] au
    INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
    INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
    WHERE au.UserID = @UserId)
BEGIN
update [Products].[RoomPriceNew] set IsApproved=@ApprovalStatus,ApprovedBy=@UserId,ApprovedOn=getdate() where IsApproved=0
update [company].[RoomPriceNew] set IsApproved=@ApprovalStatus,ApprovedBy=@UserId,ApprovedOn=getdate() where IsApproved=0--Added Rajendra
set @IsSuccess=1;
END
if @ApprovalStatus=1
begin
    SEt @Message = 'Room Rates updated Pending to Approved on ' 
    + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') 
    + '. By User: ' + CAST(@UserName as varchar(100));
    
    EXEC [app].[spInsertActivityLog] 18,1,@Message,@UserID;
end
Else
Begin 
SEt @Message = 'Room Rates updated Pending to Rejected on ' 
    + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') 
    + '. By User: ' + CAST(@UserName as varchar(100));
    
    EXEC [app].[spInsertActivityLog] 18,1,@Message,@UserID;
END

Select @IsSuccess As IsSuccess;
End