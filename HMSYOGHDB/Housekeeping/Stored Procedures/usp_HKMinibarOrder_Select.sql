
CREATE PROC [Housekeeping].[usp_HKMinibarOrder_Select] 
    @OrderId INT =0,
    @OrdereDate DATETIME=NULL,
    @FolioNumber INT=NULL,
    @GuestID INT=NULL,
    @RoomNo INT=NULL,
	@OrderStatus INT =NULL,
	@userId int =null,  
	@LocationID int =null,
	@ServiceTypeId int =null  ----Done By MURUGESH s
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON	

	IF @OrderId >0
		BEGIN			
		SELECT HMO.OrderId,HMD.OrderDetailId,HMD.ItemId,SI.Name,
				HMD.Quantity,HMD.Rate,HMD.TaxId,HMD.TaxPer,
					HMD.ServiceCharge,HMD.ReturnQty,HMD.ReturnDate,HMD.Remarks,HMD.TotalAmountBeforeTax,HMD.TotalAmountAfterTax,HMD.LineTaxAmt					
					FROM [Housekeeping].[HKMinibarOrder] HMO
					INNER JOIN [Housekeeping].[HKMinibarOrderDetails] HMD ON HMO.OrderId=HMD.OrderId	
					INNER JOIN [service].[Item] SI ON HMD.ItemId = SI.ItemID	
					where HMO.[OrderId]=@OrderId
	END
	else
		BEGIN
			 -- SELECT DISTINCT HMO.[OrderId],HMO.[OrdereDate],HMO.[FolioNumber],rr.GuestID,
				--(select CD.FirstName + ' ' + CD.LastName+' ' FROM [HMSYOGH].[contact].[Details] CD
				--	INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) AS  GuestName
				--		,HMO.[RoomNo]						
				--		,HMO.[TotalAmountBeforeTax]
				--		,HMO.[Discount],HMO.[ServiceCharge],HMO.[TaxAmount],HMO.[TotalAmountAfterTax],HMO.[CashPaid],HMO.[PINPaid]
				--		,HMO.[ReturnAmount]
				--		,HMO.[Remarks],HMO.[CreatedBy],HMO.[Createdon]
				--		,(SELECT [reservation].[fnGetMiniBarItemName](HMO.OrderId)) as ItemName
				--		,HMO.[ItemCount]
			 -- FROM [Housekeeping].[HKMinibarOrder] HMO
			 -- INNER JOIN reservation.Reservation rr on HMO.FolioNumber=rr.FolioNumber 
			 -- WHERE RR.ReservationStatusID=3 And HMO.[ServiceTypeId]=@ServiceTypeId   ----------Murugesh-----Only One Parm Passing
			 -- ORDER BY HMO.[OrderId]  DESC

					    SELECT DISTINCT HMO.[OrderId],HMO.[OrdereDate],HMO.[FolioNumber],AT.AccountTypeID,rr.GuestID,rr.ReservationID,rr.ExpectedCheckIn,rr.ExpectedCheckOut,
                        (SELECT CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
						INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID = GG.ContactID WHERE GG.GuestID = rr.GuestID) AS GuestName
						,(SELECT CA.Email FROM [contact].[Address] CA Inner join [contact].[Details] CD on CD.ContactID=CA.ContactID INNER JOIN [guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) as Email
                        ,(SELECT CA.PhoneNumber FROM [HMSYOGH].[contact].[Address] CA Inner join [contact].[Details] CD on CD.ContactID=CA.ContactID INNER JOIN [guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=rr.GuestID) as PhoneNumber
						,PR.[RoomNo],HMO.[TotalAmountBeforeTax],HMO.[Discount],HMO.[ServiceCharge],HMO.[TaxAmount],HMO.[TotalAmountAfterTax]
						,HMO.[PINPaid],HMO.[ReturnAmount],HMO.[Remarks],	HMO.[CreatedBy],HMO.[Createdon]
						,(SELECT [reservation].[fnGetMiniBarItemName](HMO.OrderId)) as ItemName
						,(case when AT.AccountTypeID in (95,96) then AT.Amount else 0 end) as CashPaid
						--,(SELECT STRING_AGG(si.Name, ', ')FROM [Housekeeping].[HKMinibarOrderDetails] HMOItem  
						-- INNER JOIN [service].[Item] si ON HMOItem.ItemId = si.ItemID WHERE HMOItem.OrderId = HMO.OrderId) AS ItemName -- Comma-separated list of item names
						,HMO.[ItemCount],HMO.[RoomNo] as RoomNos,
						ReportFooter='This is proof of your transaction. It cannot be used to claim Tax. Please note this is not an Invoice A valid Invoice for Tax purpose can only be issued by the property '
					FROM [Housekeeping].[HKMinibarOrder] HMO
					INNER JOIN reservation.Reservation rr ON HMO.FolioNumber = rr.FolioNumber 
					Left Join account.[Transaction] AT on HMO.OrderId=AT.ReferenceNo
					LEFT JOIN Products.Room PR ON HMO.RoomNo=PR.RoomID
					--INNER JOIN [contact].[Address] a ON cd.ContactID = a.ContactID
					WHERE rr.ReservationStatusID = 3 AND HMO.[ServiceTypeId] = @ServiceTypeId
					ORDER BY HMO.[OrderId] DESC;
			   
		END

		
END	