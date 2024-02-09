
CREATE PROC [Housekeeping].[usp_SplitBillServicesData]	
@MainInvoice int
--@FolioNum int = null,
--@userId int=NULL,   
--@LocationID int=NULL
			
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON 
	--DECLARE @ReservationID INT;
	--SELECT @ReservationID= ReservationID FROM [reservation].[Reservation] WHERE FolioNumber=@FolioNum
	
--		SELECT ROW_NUMBER() OVER (ORDER BY ItemDescription) AS SrNo, ItemDescription,ItemId,Quantity,Amount
--FROM (
--  	SELECT	
--	'Tarif' as ItemDescription,
--	0 as ItemId, 
--	RS.Rooms as Quantity,
--			RS.TotalPayable as Amount
--	FROM [reservation].[Reservation] RS
--	WHERE RS.ReservationID=@ReservationID --and RS.LocationID = @LocationID
--	UNION ALL
--	SELECT 
	
--	SI.[Name] as ItemDescription,
--	RS.TransId as ItemId, 
--	RS.ServiceQty as Quantity, 
--			RS.ServiceQty * RS.ServiceRate as Amount			
--	FROM [reservation].[ReservationServices] RS
--			Inner join [service].[Item] SI on RS.ServiceId = SI.ItemID
--	WHERE
--	RS.ReservationID = @ReservationID
--	and	RS.[Status] = 'A'
--) AS subquery_alias;


--	SELECT ROW_NUMBER() OVER (ORDER BY ItemDescription) AS SrNo, ItemDescription,ItemId,Quantity,Amount
--FROM (
--  	SELECT	FORMAT(RD.NightDate,'dd-MMM-yyyy')  as TransDate,
--			RD.ItemID as ItemId,
--			IT.ItemName as ItemDescription,
--			RD.Rooms as Quantity,
--			RD.UnitPriceAfterTax AS Rate, 
--			RD.LineTotal as Amount		
--	FROM [reservation].[Reservation] RS
--			inner join [reservation].[ReservationDetails] RD on RS.ReservationID = RD.ReservationID
--			inner join [Products].[Item] IT on RD.ItemID = IT.ItemID
--	WHERE RS.ReservationID=@ReservationID --and RS.LocationID = @LocationID
--	UNION ALL
--	SELECT FORMAT(RS.ServiceDate,'dd-MMM-yyyy')  AS TransDate,
--			RS.TransId as ItemId, 
--			SI.[Name] as ItemDescription, 
--			RS.ServiceQty as Quantity, 
--			RS.ServiceRate as Rate,
--			RS.ServiceQty * RS.ServiceRate as Amount			
--	FROM [reservation].[ReservationServices] RS
--			Inner join [service].[Item] SI on RS.ServiceId = SI.ItemID
--	WHERE RS.ReservationID = @ReservationID and RS.[Status] = 'A'
--) AS subquery_alias;

--select ROW_NUMBER() OVER (ORDER BY IND.InvoiceDetailId) AS SrNo, IND.InvoiceDetailId, ISNULL(IND.ItemId,0) ItemID, IND.ItemDescription, IND.Quantity, IND.TotalRate as Amount
--from [Housekeeping].[HKMISCInvoice] INV  
--INNER JOIN [Housekeeping].[HKMISCInvoiceDetails] IND on INV.InvoiceNo = IND.InvoiceNo


--where FolioNumber = @FolioNum

SELECT ROW_NUMBER() OVER (ORDER BY InvoiceNo) AS SrNo
	  ,[InvoiceDetailsId]
      ,[InvoiceNo]
      ,[TransactionDate]
      ,[ServiceId]
      ,[ServiceDescription]
      ,[SACNo]
      ,[ServiceRate]
      ,[ServiceQty]
      ,[TaxId]
      ,[TaxPercent]
      ,[AmountBeforeTax]
      ,[TaxAmount]
      ,[AmountAfterTax]
      ,[DisplaySequence]
  FROM  [reservation].[InvoiceDetails] where InvoiceNo=@MainInvoice



END	
