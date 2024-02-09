create PROCEDURE [reservation].[spGetGuestLedgerDetails_Old]   --10411,1,1,3
(	
    @FolioNo int null,	
	@LocationID int,
	@DrawerID int=null,
	@UserId int
)
AS
Begin
SET NOCOUNT ON;
  
	  DECLARE @ReservationNo int=0;
	   Declare @reservationId int;
    set @reservationId= (Select ReservationID from reservation.Reservation where FolioNumber=@FolioNo)
    DECLARE @BOOKEDBY nvarchar(100);
	DECLARE @CHECKEDINBY nvarchar(100);
	DECLARE @CHECKEDOUTBY nvarchar(100);

   set @BOOKEDBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where RI.ReservationID=@reservationId And RI.ReservationStatusID=1)
   set @CHECKEDINBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=3)
   set @CHECKEDOUTBY=(Select TOP 1 TL.[Title] + ' ' + CD.[FirstName] + (CASE When LEN(CD.[LastName]) > 0 THEN ' ' + CD.[LastName] ELSE '' END) AS FirstName from reservation.ReservationStatusLog  RI
					inner join app.[User] au on RI.UserID=au.UserID
					inner join [contact].[Details] CD on au.ContactID=CD.ContactID
					inner join [person].[Title] TL on CD.TitleID = TL.TitleID where  RI.ReservationID=@reservationId And RI.ReservationStatusID=4)
 select @ReservationNo=reservationid  from reservation.Reservation where FolioNumber=@FolioNo
 Declare @RoomNo int =(select [reservation].[fnGetReserveredRoom] (@ReservationNo))

 declare @TempTable Table(TransactionDate datetime,Particulars varchar(500),TransactionType varchar(50),VoucherNo int,Debit decimal(18,2),Credit decimal(18,2))

 if(@ReservationNo<538)
 Begin
 insert into @TempTable
	  SELECT gld.TransDate AS TransactionDate, 
			st.ServiceName as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtAfterTax as Debit, 
			0 as Credit 
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo 
	  UNION
	  SELECT atr.TransactionDateTime AS TransactionDate, 
			aat.AccountType as Particulars, 			
			att.TransactionType as TransactionType,
			TransactionID as VoucherNo, 
			0 as Debit, 
			atr.Amount as Credit 
			FROM [account].[Transaction] atr
			Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
			inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
			WHERE atr.ReservationID=@ReservationNo	
End
Else
Begin
insert into @TempTable
	  SELECT gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=18 then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtBeforeTax as Debit, 
			0 as Credit 
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo  and st.ServiceTypeID=18 
			union 
			SELECT gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=18 then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', VAT 10%'  else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			(gld.AmtAfterTax-gld.AmtBeforeTax) as Debit, 
			0 as Credit 
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo    and st.ServiceTypeID=18 
			union
			SELECT gld.TransDate AS TransactionDate, 
			case when st.ServiceTypeID=18 then st.ServiceName +' ' + isnull(convert(varchar(10),@RoomNo),'')+', ' + convert(varchar(6),Transdate,7) else st.ServiceName End as Particulars,
			st.ServiceName TransactionType,
			gld.TransRefNo as VoucherNo, 
			gld.AmtBeforeTax as Debit, 
			0 as Credit 
			FROM [account].[GuestLedgerDetails] gld
			Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
			WHERE gld.FolioNo=@FolioNo   and st.ServiceTypeID<>18 
	  UNION
	  SELECT atr.TransactionDateTime AS TransactionDate, 
			aat.AccountType as Particulars, 			
			att.TransactionType as TransactionType,
			TransactionID as VoucherNo, 
			0 as Debit, 
			atr.Amount as Credit 
			FROM [account].[Transaction] atr
			Inner Join [account].[AccountType] aat on atr.AccountTypeID=aat.AccountTypeID
			inner join account.TransactionType att on atr.TransactionTypeID=att.TransactionTypeID	
			WHERE atr.ReservationID=@ReservationNo	
End
			select *,SUM(Debit) OVER (ORDER BY TransactionDate)-SUM(Credit) OVER (ORDER BY TransactionDate) as Balance,Case when debit>0 then 'Debit' else 'Credit' end as DebitOrCredit from @TempTable order by 1
		--Select @BOOKEDBY as BookedBy,@CHECKEDINBY as CheckedInBy,@CHECKEDOUTBY as CheckedOutBy
		SELECT ISNULL(@BOOKEDBY, NULL) as BookedBy, ISNULL(@CHECKEDINBY, NULL) as CheckedInBy, ISNULL(@CHECKEDOUTBY, NULL) as CheckedOutBy
END