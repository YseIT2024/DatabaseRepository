CREATE proc [Products].[sp_UpdateCompanyContractPrice]
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
Declare @CompanyName Varchar(200);
set @oldroomprice=(Select BasePrice from [company].[RoomPriceNew] where PriceID=@PriceId)

set @CompanyName=( SELECT GC.CompanyName           
    FROM [company].[RoomPriceNew] RP 
	INNER JOIN company.RateContracts RC ON RP.ContractId=RC.RateContractID
	INNER JOIN guest.GuestCompany GC ON RC.CompanyID=GC.CompanyID Where RP.PriceID=@PriceId)
set @FromDate=(Select FromDate from [company].[RoomPriceNew] where PriceID=@PriceId)

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

Begin
update [company].[RoomPriceNew] set BasePrice=@BaseRate,CreatedBy=@UserId where PriceID=@PriceId
set @IsSuccess=1;
set @newRoomprice=(Select BasePrice from [Products].[RoomPriceNew] where PriceID=@PriceId)
SET @NotDesc = Cast(@CompanyName As VArchar(100))+' Company Rate changed for: ' + CAST(@ItemName AS varchar(100)) + ' and ' + @RoomType +' '+FORMAT(@FromDate, 'dd-MMM-yyyy')+' from  '+
               CAST(@oldroomprice AS varchar(100)) + '  To  ' + CAST(@newRoomprice AS varchar(100)) + 
               ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User: ' + CAST(@UserName AS varchar(100));
End
EXEC [app].[spInsertActivityLog] 18,1,@NotDesc,@UserId

Select @IsSuccess As IsSuccess;
End