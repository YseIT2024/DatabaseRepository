

CREATE VIEW [guest].[vwGuestFolio]
As
	SELECT gw.[WalletID]
	,gw.GuestID
	,gw.[ReservationID]
	,act.AccountType
	,gw.AccountTypeID
	,CASE WHEN gw.DateID IS NULL THEN '' ELSE FORMAT(d.[Date], 'dd-MMM-yyyy') END [Date]
	,FORMAT(acd.[AccountingDate], 'dd-MMM-yyyy') [AccountingDate]
	,CASE WHEN tt.TransactionFactor = -1 THEN 
		(CASE WHEN gw.AccountTypeID = 82 THEN (ISNULL(ABS(gw.[Amount]),0) - ISNULL(ABS(gw.[Amount]*dis.Percentage/100),0)) 
			ELSE ISNULL(ABS(gw.[Amount]),0) END) ELSE 0 END [Debit]
	,CASE WHEN tt.TransactionFactor = 1 THEN  ISNULL(ABS(gw.[Amount]),0) ELSE 0 END [Credit]
	,CASE WHEN gw.AccountTypeID = 82 THEN CASE WHEN gw.[IsVoid] = 1 THEN 'Yes' ELSE 'No' END ELSE '' END [Void]	
	,gw.IsVoid
	,ISNULL(gw.Remarks,'') [Remarks]
	,ISNULL(gw.ServiceID,0) [ServiceID]
	,ISNULL(sp.TransactionID,0) [TransactionID]
	FROM [guest].[GuestWallet] gw
	INNER JOIN account.AccountType act ON gw.AccountTypeID = act.AccountTypeID 
	INNER JOIN account.TransactionType tt ON gw.TransactionTypeID = tt.TransactionTypeID	
	INNER JOIN [account].[AccountingDates] acd ON gw.AccountingDateID = acd.AccountingDateID	
	LEFT JOIN general.[Date] d ON gw.DateID = d.DateID
	LEFT JOIN reservation.RoomRate rat ON gw.ReservedRoomRateID = rat.ReservedRoomRateID
	LEFT JOIN reservation.Discount dis ON rat.DiscountID = dis.DiscountID
	LEFT JOIN reservatION.ServicePayment sp ON gw.ServiceID = sp.ServiceID

