-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[InsertNightRate]
	
AS
BEGIN
	--Insert Into [account].[GuestLedgerDetails] 
	--	(FolioNo,TransDate, ServiceId, TransRefNo, AmtBeforeTax,AmtAfterTax,
	--	TaxId,TaxPer,PaidStatus,TransStatus,Remarks,IsActive,CreatedBy,CreatedOn,AmtTax)
	--SELECT rr.FolioNumber,rd.NightDate,18,rr.ReservationID,
	--rd.linetotal-rd.totaltaxamount,rd.linetotal,
	--3,10,0,1,concat('Room Charges, ',[reservation].[fnGetReserveredRoom](rr.ReservationID),', ', format(rd.NightDate,'MMM-dd')),
	--1,85,GETDATE(),rd.totaltaxamount
	--FROM RESERVATION.Reservation rr
	--INNER JOIN reservation.reservationdetails rd on rr.ReservationID=rd.ReservationID
	--WHERE rr.ReservationStatusID=3 and -- rr.ReservationID=563 and 
	--format(rd.NightDate,'yyyy-MM-dd')=FORMAT( GETDATE(),'yyyy-MM-dd')

	Insert Into [account].[GuestLedgerDetails] 
		(FolioNo,TransDate, ServiceId, TransRefNo, AmtBeforeTax,AmtAfterTax,
		TaxId,TaxPer,PaidStatus,TransStatus,Remarks,IsActive,CreatedBy,CreatedOn,
		AmtTax,IsComplimentary,ComplimentaryPercentage,UnitPriceBeforeDiscount,Discount,DiscountPercentage)
	SELECT rr.FolioNumber,--rd.NightDate,
	CONVERT(DATETIME, CONVERT(VARCHAR, rd.NightDate, 23) + ' ' + CONVERT(VARCHAR, GETDATE(), 108), 121) AS NightDate,
	18,rr.ReservationID,
	rd.linetotal-rd.totaltaxamount,rd.linetotal,
	3,10,0,1,concat('Room Charges, ',[reservation].[fnGetReserveredRoom](rr.ReservationID),', ', format(rd.NightDate,'MMM-dd')),
	1,85,GETDATE(),rd.totaltaxamount,case when rr.ReservationTypeID=10 then 1 else 0 end, case when rr.ReservationTypeID=10 then 100 else 0 end
	,rd.UnitPriceBeforeDiscount,rd.Discount,rd.DiscountPercentage
	FROM RESERVATION.Reservation rr
	INNER JOIN reservation.reservationdetails rd on rr.ReservationID=rd.ReservationID
	WHERE rr.ReservationStatusID=3 and format(rd.NightDate,'yyyy-MM-dd')=FORMAT( GETDATE(),'yyyy-MM-dd')
	and rr.FolioNumber not in (select FolioNo from 
		[account].[GuestLedgerDetails]  where FolioNo=rr.FolioNumber  
		and ServiceId=18 and format(TransDate,'yyyy-MM-dd')=FORMAT( GETDATE(),'yyyy-MM-dd'))
	END

