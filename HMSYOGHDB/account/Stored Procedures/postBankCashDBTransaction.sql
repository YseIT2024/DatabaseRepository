Create Proc [account].[postBankCashDBTransaction] --582
@Transactionid int
As
Begin

DECLARE  @TempStatus TABLE ([IsSuccess] INT, [Message] VARCHAR(max))	
DECLARE  @TransSummary TABLE (Id int identity(1,1), currencyid int, Amount decimal(18,4))	
Declare @tranmode int; 
DECLARE @PosiveAmount Decimal(18,6) 
declare @Incr int=1
declare @Rowcount int

DECLARE @CompanyId int=13
DECLARE @ReferenceId int=@Transactionid
DECLARE @TransactionModeId int
DECLARE @TransactionTypeId int
DECLARE @CurrencyId int
DECLARE @Amount decimal(18,4)
DECLARE @ContactId int
DECLARE @UserId int
DECLARE @TillId int
DECLARE @Remarks nvarchar(1125)
DECLARE @ReferenceTypeId int=2

select @TransactionModeId=case when TransactionTypeID=1 then 2 else 1 end
		,@ContactId=ContactID
		,@UserId=UserID
		,@TillId=DrawerID
		,@Remarks=Remarks
from account.[Transaction] with (nolock) where TransactionID=@Transactionid

if(@TillId not in(3,8))--Till Should be Front Desk or airwallex 
Begin
	set @TillId=3
End

if exists(select CurrencyID from account.TransactionSummary with (nolock) where TransactionID=@Transactionid)
Begin
	insert into @TransSummary select Currencyid,abs(amount) from account.TransactionSummary with (nolock) where TransactionID=@Transactionid
	set @Rowcount =(select count(*) from @TransSummary)

	while @Incr <=@Rowcount
	Begin
		select @CurrencyId =Currencyid,@Amount=amount from @TransSummary where Id=@Incr
	--	INSERT INTO @TempStatus
	--	exec [BankCashDB].[Finance].[TransactionDetails] @CompanyId,@TransactionID, @TransactionModeId,1,@CurrencyID,@Amount,@ContactID,@UserID,@TillId,@Remarks,@ReferenceTypeId

	set @Incr +=1
	end

End
else
Begin
select @CurrencyId=ActualCurrencyID,@Amount=abs(ActualAmount)
from account.[Transaction] with (nolock) where TransactionID=@Transactionid
--INSERT INTO @TempStatus
--exec [BankCashDB].[Finance].[TransactionDetails] @CompanyId,@TransactionID, @TransactionModeId,1,@CurrencyID,@Amount,@ContactID,@UserID,@TillId,@Remarks,@ReferenceTypeId

End





End