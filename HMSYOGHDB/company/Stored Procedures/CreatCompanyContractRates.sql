CREATE Proc [company].[CreatCompanyContractRates]-- 115,1,'01-Jan-2024','31-Jan-2024',290.0000,90,80,35,3
	@ItemId int,
	@RateContractId int,
	@CurrencyId int,
	@FromDate date,
	@Todate date,
	@BaseRate decimal(18,2),
	@AddChild decimal(18,2),
	@AddPax decimal(18,2),
	@AddChildSr decimal(18,2),
	@UserId int
as
Begin

declare @Message varchar(100);
DECLARE @NotDesc varchar(max) = '';
DECLARE @ItemName varchar(max)='';
Declare @RoomTypeName  varchar(max)='';--Added Rajendra
Declare @RoomType int;
declare @IsSuccess int=0;
declare @IsWeekend bit;
declare @Todate1 datetime;
declare @fromdate1 datetime;
Declare @UserName varchar(100);
Declare @CompanyId int;

Declare @CompanyName varchar(100);

--Declare @CompanyName Varchar(100);
set @fromdate1=@FromDate;
set @Todate1=@Todate
Set @RoomType =(Select SubCategoryID from Products.Item Where ItemID=@ItemId)
set @RoomTypeName=(Select PS.Name from Products.Item IM
INNER JOIN Products.SubCategory PS ON IM.SubCategoryID=PS.SubCategoryID Where IM.ItemID=@ItemId);--Added Rajendra
Set @ItemName=(Select ItemName from  Products.Item Where ItemID=@Itemid);
set @CompanyId=(Select CompanyID from company.RateContracts Where RateContractID=@RateContractId);
Set @CompanyName=(Select CompanyName from guest.GuestCompany Where CompanyID=@CompanyId);
Set @UserName=(SELECT TL.[Title] + ' ' + CD.[FirstName] + (CASE WHEN LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END)
            FROM app.[User] au
            INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID
            INNER JOIN [person].[Title] TL ON CD.TitleID = TL.TitleID
            WHERE au.UserID = @UserId);
		
while(@FromDate<=@Todate)
Begin
set @IsWeekend=0
if(DATEPART(DW, @FromDate)=1 or DATEPART(DW, @FromDate)=7)
Begin
set @IsWeekend=1
end

if not exists(select itemid from [company].[RoomPriceNew] where ItemID=@ItemId and FromDate=@FromDate and IsApproved in (0,1))
Begin
insert into [company].[RoomPriceNew] ([ItemID],[ContractId]
      ,[PriceTypeID]      ,[LocationID]      ,[FromDate]      ,[CurrencyID]
      ,[BasePrice]      ,[BasePriceSingle]      ,[Commission]      ,[Discount]
      ,[AddPax]      ,[AddChild]      ,[SalePrice]      ,[SalePriceSingle]
      ,[Remarks]      ,[IsOnDemand]      ,[IsWeekEnd]      ,[Priority]
      ,[CreatedBy]      ,[CreateDate]      ,[AddChildSr]      ,[IsApproved])
select @ItemId,@RateContractId,1,1,@FromDate,@CurrencyId,@BaseRate,@BaseRate,0,0,@AddPax,@AddChild
,@BaseRate,@BaseRate,'',0,@IsWeekend,0,@UserId,getdate(),@AddChildSr,0
End
set @FromDate=DATEADD(DD,1,@FromDate)
set @IsSuccess=1
set @Message=Cast(@CompanyName As varchar(200))+' Company Contract Rates Created Successfully';

SET @NotDesc = @Message + ' for Item: ' + STR(@ItemID) + ',' + @ItemName + ' RoomType: ' + STR(@RoomType) + ', ' + @RoomTypeName + 'Base Rate: '
+ Cast(@BaseRate As varchar(100))+
' Between dates ' + FORMAT(@fromdate1,'dd-MMM-yyyy') + ' And ' + FORMAT(@Todate1,'dd-MMM-yyyy') + 
' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '. By User: ' + CAST(@UserName as varchar(100));

End
EXEC [app].[spInsertActivityLog] 18,1,@NotDesc,@UserID
Select @IsSuccess As IsSuccess, @Message As Message
End