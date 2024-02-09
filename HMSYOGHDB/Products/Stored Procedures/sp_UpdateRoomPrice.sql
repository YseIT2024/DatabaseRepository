CREATE proc [Products].[sp_UpdateRoomPrice] --206,400.00,85
@PriceId int,
@BaseRate decimal(18,4),
@UserId int
as
Begin
declare @IsSuccess int=0;
declare @oldroomprice decimal(18,4);
declare @newRoomprice decimal(18,4);
declare @UserName varchar(300);
declare @NotDesc varchar(300);
declare @ItemName varchar(200);
declare @RoomType  varchar(200);
declare @ItemId int;
declare @FromDate datetime;
set @oldroomprice=(Select BasePrice from [Products].[RoomPriceNew] where PriceID=@PriceId)
set @FromDate=(Select FromDate from [Products].[RoomPriceNew] where PriceID=@PriceId)

Set @UserName=(SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
            FROM app.[User] au
            INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
            INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
            WHERE au.UserID = @UserId);
set @ItemId=(Select ItemID from [Products].[RoomPriceNew] where PriceID=@PriceId)
set @ItemName=(Select ItemName from Products.Item where ItemID=@ItemId)
set @RoomType=
(select top 1
a.Name RoomType
from Products.SubCategory a 
inner join  Products.Item b on a.SubCategoryID=b.SubCategoryID where a.CategoryID=1 and b.ItemID=@ItemId)
BEGIN
update [Products].[RoomPriceNew] set BasePrice=@BaseRate,CreatedBy=@UserId where PriceID=@PriceId
set @IsSuccess=1;
set @newRoomprice=(Select BasePrice from [Products].[RoomPriceNew] where PriceID=@PriceId)
--SET @NotDesc =  'Room Rate changed for: ' + STR(@ItemName) + '  and ' + @RoomType + ' from '+
--CAST(@oldroomprice AS varchar(100)) + ' To '+ CAST(@newRoomprice AS varchar(100)) +' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm')
--+ '. By User: ' + CAST(@UserName as varchar(100));
SET @NotDesc = 'Room Rate changed for: ' + CAST(@ItemName AS varchar(100)) + ' and ' + @RoomType +' '+FORMAT(@FromDate, 'dd-MMM-yyyy')+' from  '+
               CAST(@oldroomprice AS varchar(100)) + '  To  ' + CAST(@newRoomprice AS varchar(100)) + 
               ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User: ' + CAST(@UserName AS varchar(100));

END
EXEC [app].[spInsertActivityLog] 18,1,@NotDesc,@UserId 
Select @IsSuccess As IsSuccess;
End


