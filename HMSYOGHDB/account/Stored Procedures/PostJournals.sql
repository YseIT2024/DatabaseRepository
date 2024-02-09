CREATE Proc [account].[PostJournals]
@TranTbl [Account].[BOTranTbl] Readonly
as
Begin
Begin try
	Declare @xmldata as xml
	--Declare @TempJ table(ReferenceId int,JournalId int)
	SET @xmldata = (
		  SELECT [CompanyId], [AccountReferenceNumber], [AccountingDate], [ContactID], [FinancialTypeId], [CurrencyId], 
		  [MainCurrencyRate], [LocalCurrencyRate], [Amount], [ReferenceId], [ReferenceTypeId], [InvoiceNumber], [TransactionUserId], 
		  [Description], [Comments], [CollectorId],[ContactTypeId],AdditionalColumns,AdditionalColumnValues  from @TranTbl
		  FOR XML RAW('JRINSERTION'), TYPE)

	--	insert into @TempJ
		exec  [AccountsDB].[Account].[InsertAccountTranactions] @xmldata
End Try
Begin Catch
declare @ErrorMessage varchar(max)=(select ERROR_MESSAGE())
	exec  [AccountsDB].account.insertErrorLogs @ErrorMessage
End Catch
End