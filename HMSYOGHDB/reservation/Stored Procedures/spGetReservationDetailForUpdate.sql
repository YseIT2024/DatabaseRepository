
CREATE PROCEDURE [reservation].[spGetReservationDetailForUpdate]  --6645, 1    --2386,1
(	
	@ReservationID int,
	@LocationID int	
)
AS
BEGIN	
	
SELECT r.[ReservationID]   	,r.[ReservationTypeID]
	--,cd.TitleID
	,[ReservationModeID]	,r.[ExpectedCheckIn]	,r.[ExpectedCheckOut]		,r.[GuestID]
	,r.[Adults]	,r.[Children]
	--,r.[ExtraAdults]
	,r.[Rooms]	,r.[Nights]	,r.[ReservationStatusID]	,[Hold_TransactionModeID]	
	,ISNULL(g.GroupCode,'') [GroupCode]	
	,ISNull(cd.[FirstName]	 ,'') [FirstName]	,ISNull(cd.[LastName]	 ,'') [LastName]
	,ISNull(cd.[TitleID]	 ,0) [TitleID]	,ISNull(a.[Street]	 ,'') [Street]
	,ISNull(a.[City]		 ,'') [City]	,ISNull(a.[State]		 ,'') [State]
	,ISNull(a.[ZipCode]	 ,'') [ZipCode]	,ISNull(a.[CountryID]	 ,0) [CountryID]
	,ISNull(a.[Email]		 ,'') [Email]	,ISNull(a.[PhoneNumber],'') 	[PhoneNumber]
	--,Discount           --Commented By Somnath
	,r.AdditionalDiscount Discount   -- Added By Somnath
	,r.CompanyID ,r.CompanyTypeID ,
	r.TotalAmountBeforeTax,r.TotalTaxAmount, r.TotalAmountAfterTax,r.AdditionalDiscount, r.AdditionalDiscountAmount,r.TotalPayable,r.SalesTypeID , r.AdditionalDiscount      
	FROM [reservation].[Reservation] r
	Full JOIN [reservation].[vwReservationDetails] vr ON r.ReservationID = vr.ReservationID
	Full JOIN [guest].[Guest] g ON r.GuestID = g.GuestID
	Full JOIN [contact].[Details] cd ON g.ContactID = cd.ContactID
	Full JOIN [person].[Title] t ON cd.TitleID = t.TitleID
	Full JOIN [contact].[Address] a ON cd.ContactID = a.ContactID
	Full JOIN [general].[Country] c ON a.CountryID = c.CountryID
	WHERE r.ReservationID = @ReservationID  AND r.LocationID = @LocationID	

	SELECT
	ISNull(r.RoomID,0) RoomID, 	ISNull(r.RoomNo,0) RoomNo,	ISNull(rt.SubCategoryID,ISNull(rrt.SubCategoryID,0)) RoomTypeID,
	ISNull(rt.[Name],ISNull(rrt.[Name],'')) RoomType, 	ISNull(re.Adults,0) Adults, 	ISNull(re.Children,0) Children,
	ISNull(re.ExtraAdults,0) ExtraAdults,	ISNull(rat.Rate,0) Rate,	ISNull(rat.RateID,0) RateID, 	
	ISNull(c.CurrencySymbol,'') CurrencySymbol,	ISNull(SUM(rat.Rate),0) [Total]
	FROM reservation.Reservation re
	Full Join reservation.ReservationDetails rd ON re.ReservationID = rd.ReservationID
	Full JOIN reservation.ReservedRoom rr ON re.ReservationID = rr.ReservationID AND rr.IsActive = 1
	Full JOIN reservation.RoomRate rat ON rr.ReservedRoomID = rat.ReservedRoomID AND rat.IsActive = 1 AND rat.IsVoid = 0
	Full JOIN products.Room r ON rr.RoomID = r.RoomID
	Full Join Products.SubCategory rt  ON rt.SubCategoryID = r.SubCategoryID
	Full Join Products.Item PIT ON PIT.ItemID=rd.ItemID
	Full Join Products.SubCategory rrt  ON PIT.SubCategoryID = rrt.SubCategoryID 
	--INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID
	Full JOIN currency.Currency c ON rr.RateCurrencyID = c.CurrencyID
	WHERE re.ReservationID = @ReservationID
	GROUP BY r.RoomID, r.RoomNo,
	--rt.RoomTypeID, rt.RoomType, 
	re.Adults, re.Children, re.ExtraAdults, rat.Rate, rat.RateID, c.CurrencySymbol, ISNull(rt.SubCategoryID,ISNull(rrt.SubCategoryID,0)) ,
	ISNull(rt.[Name],ISNull(rrt.[Name],'')) 
	

	SELECT	
	ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 1),'') [StaffNote]   	   
	,ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 3),'') [GuestNote]   	 
	,ISNULL((SELECT [Note] FROM [reservation].[Note] WHERE ReservationID = @ReservationID AND NoteTypeID = 4),'') [Remarks]


	Select  
	IT.ItemID ItemID,	IT.ItemCode,	IT.ItemName,	SC.SubCategoryID,
	Sc.Description SubCategory,	RD.NightDate FromDate,	RD.Adults Adult,	RD.Children Child,
	RD.ExtraChildren ExChild,	RD.ExtraChildrenSr ExChildSr,	RD.ExtraAdults ExAdult,	1,
	Rooms RoomCount,	RD.Discount Discount,	--RD.UnitPriceAfterDiscount SalePrice,
	--(RD.UnitPriceAfterTax-RD.TotalTaxAmount) SalePrice  -- BeforeTax,	
	RD.UnitPriceBeforeDiscount SalePrice
	,RD.TotalTax,	RD.UnitPriceAfterTax NetTotal,
	RD.TotalTaxAmount TaxAmount, 	RD.UnitPriceAfterTax FixSalePrice,	RD.LineTotal BeforeTax,	RD.LineTotal 
		from [reservation].[ReservationDetails] RD
		INNER JOIN [Products].[Item] IT ON RD.ItemID = IT.ItemID
		INNER JOIN [Products].SubCategory SC ON IT.SubCategoryID = SC.SubCategoryID
		where ReservationID = @ReservationID

	select DT.ItemID,TaxName,PT.TaxID,TaxRate
	, CASE WHEN RD.Adults>1 OR RD.Children>0 
			THEN ISNULL((((PRP.SellRate)*ISNULL(GT.TaxRate,0))/100),0)  
			ELSE ISNULL((((PRP.SellRate)*ISNULL(GT.TaxRate,0))/100),0)  
			END TaxAmount
	from [reservation].[ReservationDetails] RD
	Full JOIN [Products].[Item] DT ON RD.ItemID = DT.ItemID
	Full join [guest].[GuestCompanyRateContract] PRP on PRP.ItemID=DT.ItemID
	Full join Products.Tax PT on DT.ItemID=PT.ItemID
	Full join general.Tax GT on GT.TaxID=PT.TaxID
	Where RD.ReservationID=@ReservationID
END


