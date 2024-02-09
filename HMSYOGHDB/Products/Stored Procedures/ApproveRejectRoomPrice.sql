CREATE proc [Products].[ApproveRejectRoomPrice]
@RoomStatus  [Products].[TblRoomRateStatus] readonly,
@CompanyStatus [Products].[TblContractRateStatus] readonly,
@UserId int
as
Begin
declare @IsSuccess int=0;
DECLARE @Message varchar(200);
Declare @UserName varchar(100);
DECLARE @IsApproved BIT;
Set @IsApproved=(Select IsApproved
FROM @RoomStatus);

Set @UserName = (
    SELECT TL.[Title] + ' ' + CD.[FirstName] + 
    (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
    FROM app.[User] au
    INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
    INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
    WHERE au.UserID = @UserId
);

BEGIN
    update t1 
    set t1.IsApproved = t2.Isapproved,
    t1.ApprovedBy = @UserId,
    t1.ApprovedOn = getdate()
    from [Products].[RoomPriceNew] t1 
    inner join @RoomStatus t2 
    on t1.PriceID = t2.PriceId;

	update t1 
    set t1.IsApproved = t2.Isapproved,
    t1.ApprovedBy = @UserId,
    t1.ApprovedOn = getdate()
    from [company].[RoomPriceNew] t1 
    inner join @CompanyStatus t2 
    on t1.PriceID = t2.companypriceId;
    
    set @IsSuccess = 1;
END
if @IsApproved=1
begin
    SEt @Message = 'Room Rates updated Pending to Approved on ' 
    + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') 
    + '. By User Name: ' + CAST(@UserName as varchar(100));
    
    EXEC [app].[spInsertActivityLog] 18,1,@Message,@UserID;
end
Else
BEGIN
 SEt @Message = 'Room Rates updated Pending to Rejected on ' 
    + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') 
    + '. By User Name: ' + CAST(@UserName as varchar(100));
    
    EXEC [app].[spInsertActivityLog] 18,1,@Message,@UserID;
END

Select @IsSuccess As IsSuccess;
END