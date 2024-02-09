
CREATE PROCEDURE [service].[sp_GetMiscellaneousInvoiceReportDetails] 
(
	@InvoiceNo int
)
AS
BEGIN
	--SET XACT_ABORT ON will cause the transaction to be uncommittable  
	--when the constraint violation occurs.   
	SET XACT_ABORT ON; 

	DECLARE @ReservationID INT;
	DECLARE @ActualCheckIn datetime;
	DECLARE @ActualCheckOut datetime;
	DECLARE @ActualStay int;
	DECLARE @RateCurrencyID INT;
	DECLARE @VatAmount DECIMAL (8,2);
	DECLARE @ServiceTaxAmount DECIMAL (8,2);


	
		BEGIN

		update [Housekeeping].[HKMISCInvoice] set PrintStatus = PrintStatus + 1 where [InvoiceNo] = @InvoiceNo

		Select MISC.[InvoiceNo], MISC.[InvoiceDate], MISC.[FolioNumber], MISC.[GuestID], CD.[FirstName], MISC.[RoomNo] , 
		MISC.[TotalAmountAfterTax] as Total, -- Since there is no Tax as of now.
		MISC.[TaxAmount], MISC.[TotalAmountAfterTax] as NetTotal ,[CashPaid] + [PINPaid] as Received, [ReturnAmount] as Balance,
		[PrintStatus],
		----> DONE BY MURUGESH S
		(select CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
					INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=MISC.GuestID) AS  GuestName,RR.ReservationID
					---> DONE BY MURUGESH S <----

		from [Housekeeping].[HKMISCInvoice] MISC 
		INNER JOIN reservation.Reservation RR ON MISC.FolioNumber=RR.FolioNumber
		inner join [guest].[Guest] GT on MISC.GuestID = GT.GuestID
		inner join [contact].[Details] CD On GT.ContactID = CD.ContactID
		where MISC.[InvoiceNo] = @InvoiceNo	

		select [ItemDescription], [Quantity], [Rate], [TaxPer], [TotalRate],
		ROW_NUMBER() Over (partition by InvoiceNo order by ItemDescription) As [SN]
		from [Housekeeping].[HKMISCInvoiceDetails] where [InvoiceNo] = @InvoiceNo		


		END			
END








