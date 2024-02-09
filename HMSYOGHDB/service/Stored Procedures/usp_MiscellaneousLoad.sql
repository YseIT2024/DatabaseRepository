CREATE PROC [service].[usp_MiscellaneousLoad]
    
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
   
	
	select MSIN.[InvoiceNo]
	  ,RS.[ReservationID]
      ,MSIN.[FolioNumber]
      ,MSIN.[GuestID]
	  ,CD.FirstName + ' ' + CD.LastName AS GuestName
      ,MSIN.[RoomNo]
      ,MSIN.[InvoiceDate]
      ,MSIN.[TotalAmountBeforeTax]
      ,MSIN.[Discount]
      ,MSIN.[ServiceCharge]
      ,MSIN.[TaxAmount]
      ,MSIN.[TotalAmountAfterTax]
      ,MSIN.[CashPaid]
      ,MSIN.[PINPaid]
      ,MSIN.[ReturnAmount]
      ,MSIN.[InvoiceStatus]
      ,MSIN.[PrintStatus]
      ,MSIN.[Remarks]
      ,MSIN.[CreatedBy]
      ,MSIN.[Createdon]
      ,MSIN.[ModifiedOn]
      ,MSIN.[ModifiedBy]
      ,MSIN.[ItemCount]
      ,MSIN.[IsActive] 
	  ,RS.[ReservationID]
	  from [Housekeeping].[HKMISCInvoice] MSIN
	  INNER JOIN [reservation].[Reservation] RS ON MSIN.FolioNumber = RS.FolioNumber
	  INNER JOIN [guest].[Guest] GS ON RS.GuestID = GS.GuestID
	  INNER JOIN [contact].[Details] CD ON GS.ContactID = CD.ContactID
	  order by MSIN.[InvoiceNo] DESC
    
END
