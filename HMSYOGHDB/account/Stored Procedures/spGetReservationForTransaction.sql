CREATE PROCEDURE [account].[spGetReservationForTransaction]--10901,1
(	
	--@FolioNo varchar(20),
	@FolioNo int,
	@LocationID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ReservationID int;
	DECLARE @RateCurrencyID int;
	DECLARE @RoomNo int;
	DECLARE @RoomType varchar(30);
	DECLARE @FolioNumber int;
	Set @FolioNumber=(Select FolioNumber from reservation.Reservation where ReservationID=@FolioNo)


	--SELECT  r.ReservationID
	-- R.CurrencyID
	--FROM reservation.Reservation r
	----INNER JOIN reservation.ReservedRoom rm ON r.ReservationID = rm.ReservationID
	--WHERE r.LocationID = @LocationID AND r.ReservationStatusID IN (3,4)	AND r.FolioNumber = CAST(STUFF(@FolioNo, 1, 3, '') as int)


	SELECT @ReservationID = r.ReservationID
	,@RateCurrencyID = R.CurrencyID
	FROM reservation.Reservation r
	--INNER JOIN reservation.ReservedRoom rm ON r.ReservationID = rm.ReservationID
	WHERE r.LocationID = @LocationID AND r.ReservationStatusID IN (1,3,4)	
	AND r.ReservationID = @FolioNo
	
	
	--;WITH Room_cte
	--as
	--(
	--	SELECT TOP 1 r.RoomNo, rt.RoomType 
	--	FROM reservation.ReservedRoom rr
	--	INNER JOIN room.Room r ON rr.RoomID = r.RoomID		
	--	INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID		
	--	WHERE rr.ReservationID = @ReservationID AND  rr.IsActive = 1
	--)

	--SELECT @RoomNo = Room_cte.RoomNo, @RoomType = Room_cte.RoomType
	--FROM Room_cte

	--SELECT v.ReservationID
	--,v.GuestID
	----,@RoomType +'-'+ CAST(@RoomNo as varchar(5)) Room
	--,v.ReservationStatus [Status]
	--,v.FullName
	--,fn.TotalAmount
	--,fn.DiscountAmount
	--,vdcomp.ComplimentaryAmount Compliment
	--,vdcomp.VoidAmount VoidAmount
	--,(SELECT [account].[fnGetReservationPayment](@ReservationID)) OtherPayment
	--,v.BillTo
	--,@RateCurrencyID CurrencyID
	--FROM [reservation].[vwReservationDetails] v		
	--CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](v.ReservationID))vdcomp--TODO: Required?
	--CROSS APPLY (SELECT * FROM [reservation].[fnGetReservationRoomBill](v.ReservationID))fn
	--WHERE v.ReservationID = @ReservationID


	-------Commented by Arabinda on 2023-09-14  to get the balance from the guest ledger-----------

	------SELECT RR.ReservationID
	------,RR.GuestID
	--------,@RoomType +'-'+ CAST(@RoomNo as varchar(5)) Room
	------,rs.ReservationStatus [Status]
	------,C.FirstName+' '+isnull(c.LastName,'') as FullName
	------,RR.TotalPayable as TotalAmount ---TODO?
	------,RR.AdditionalDiscount as  DiscountAmount
	------,(select isnull(sum(Amount),0) from account.[Transaction] where ReservationID=RR.ReservationID and AccountTypeID=20) as Compliment
	------,(select isnull(sum(Amount),0) from account.VoidTransaction where ReservationID=RR.ReservationID) as VoidAmount
	------,(select isnull(sum(Amount),0) from account.[Transaction] where ReservationID=RR.ReservationID and AccountTypeID=5) as OtherPayment
	------,comp.CompanyName as BillTo
	------,0 as CurrencyID
	------FROM [reservation].Reservation RR	
	------join [reservation].ReservationStatus RS on RR.ReservationStatusID=rs.ReservationStatusID
	------join [guest].[Guest] G on RR.GuestID=G.GuestID
	------join [contact].[Details]  C on G.ContactID=c.ContactID
	------left join [general].[Company] comp on RR.CompanyID=comp.CompanyID
	--------join VoidTransaction VT on RR.ReservationID=VT.ReservationID
	--------CROSS APPLY (SELECT * FROM [reservation].[fnGetVoidAndComplimentaryAmount](v.ReservationID))vdcomp--TODO: Required?
	--------CROSS APPLY (SELECT * FROM [reservation].[fnGetReservationRoomBill](v.ReservationID))fn
	------WHERE RR.ReservationID = @ReservationID

	-------------------- Comment End ----------------------------
	--------------------Added by Arabinda on 2023-09-14  to get the balance from the guest ledger ----------------------------
	SELECT RR.ReservationID	,RR.GuestID
	--,@RoomType +'-'+ CAST(@RoomNo as varchar(5)) Room
	,rs.ReservationStatus [Status]
	,C.FirstName+' '+isnull(c.LastName,'') as FullName
	,(SELECT isnull(SUM(AmtAfterTax),0) from [account].[GuestLedgerDetails] where FolioNo=@FolioNumber) as TotalAmount	
	,RR.AdditionalDiscount as  DiscountAmount
	,(select isnull(sum(Amount),0) from account.[Transaction] where ReservationID=RR.ReservationID) as Compliment
	,(select isnull(sum(Amount),0) from account.VoidTransaction where ReservationID=RR.ReservationID) as VoidAmount
	,0 as OtherPayment
	,comp.CompanyName as BillTo
	,0 as CurrencyID
	FROM [reservation].Reservation RR	
	join [reservation].ReservationStatus RS on RR.ReservationStatusID=rs.ReservationStatusID
	join [guest].[Guest] G on RR.GuestID=G.GuestID
	join [contact].[Details]  C on G.ContactID=c.ContactID
	left join [general].[Company] comp on RR.CompanyID=comp.CompanyID	
	WHERE RR.ReservationID = @FolioNo
	--------------------End ----------------------------

END

 --SELECT * FROM account.[Transaction] where ReservationID=4967
 --(select isnull(sum(Amount),0) from account.[Transaction] where ReservationID=4967) as Compliment


 Select * from reservation.ReservationDetails where ReservationID=6611
 Select * from reservation.Reservation  where ReservationID=6611


 Select * from account.[Transaction] where ReservationID=6611