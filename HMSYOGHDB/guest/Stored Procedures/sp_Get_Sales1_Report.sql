	CREATE proc guest.sp_Get_Sales1_Report     --'2024-01-01' ,'2024-02-07'  --'2/1/2024' ,'2/7/2024' 
	@CheckInDate date ,
	@CheckOutDate date 


	as
	begin
	select BookingDateandtime,
	CheckInDate,
	CheckOutDate,
	RoomType,
	ReservationID,
	Manager,
	BookedBy,
	EntryBy,
	GuestName,
	Roomnumber,
	NetRate,
	NoOfNights,
	TotalReceivable,
	VAT,
	NetSalesRevenue,
	SalesMethod,
	BilledTo,
	PaymentMethod,
	PaymentTerm,
	CreditSalesAuthorization
	from guest.Sales1
WHERE CheckInDate >= @CheckInDate
     AND CheckOutDate <= @CheckOutDate
	end


	--delete  from guest.Sales1
	--where BookedBy ='Mr. Amir'