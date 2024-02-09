-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE Proc [room].[spGetRoomRateUpdateHistory] --1, 0
(
	@LocationID INT,
	@RoomTypeID INT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @RoomTypeID = 0
		BEGIN
			SELECT r.RateID
			,l.[LocationName]	
			,r.RateCode
			,d.Duration 'RateType'	
			,CASE WHEN r.RoomTypeID IS NULL THEN '-' ELSE rt.RoomType + ' (' + rt.Description + ')' END [RoomType]	
			,FORMAT(r.ActivationDate,'dd-MMM-yyyy') [ActivationDate]
			,ISNULL(FORMAT(fd.[Date],'dd-MMM-yyyy'),'') [FromDate]
			,ISNULL(FORMAT(td.[Date],'dd-MMM-yyyy'),'') [ToDate]
			,CASE WHEN r.Adult1PriceID IS NOT NULL THEN cA1.CurrencySymbol + CAST(pA1.Rate as varchar) ELSE '-' END [RateFor1Adult] 
			,CASE WHEN r.Adult2PriceID IS NOT NULL THEN cA2.CurrencySymbol + CAST(pA2.Rate as varchar) ELSE '-' END [RateFor2Adult]
			,CASE WHEN r.Adult3PriceID IS NOT NULL THEN cA3.CurrencySymbol + CAST(pA3.Rate as varchar) ELSE '-' END [RateFor3Adult]
			,CASE WHEN r.Adult4PriceID IS NOT NULL THEN cA4.CurrencySymbol + CAST(pA4.Rate as varchar) ELSE '-' END [RateFor4Adult]
			,CASE WHEN r.ExtraAdultPriceID IS NOT NULL THEN cEx.CurrencySymbol + CAST(pEx.Rate as varchar) ELSE '-' END [RateForExtraAdult]
			,CASE WHEN r.ExtraChildPriceID IS NOT NULL THEN cCh.CurrencySymbol + CAST(pCh.Rate as varchar) ELSE '-' END [RatePerChild]  
			,r.Description [Description]
			,CASE WHEN r.IsActive = 0 THEN 'De-Activated' ELSE 'Activated' END Status
			,[Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName)) AS  [User]
			FROM room.Rate r
			INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	
			INNER JOIN general.Location l ON r.LocationID = l.LocationID		
			INNER JOIN reservation.Duration d ON r.DurationID = d.DurationID
			INNER JOIN [app].[User] u ON r.UserID = u.UserID
			INNER JOIN contact.Details cd ON u.ContactID = cd.ContactID
			LEFT JOIN [person].[Title] t ON cd.TitleID = t.TitleID	
			LEFT JOIN general.[Date] fd ON r.FromDateID = fd.DateID AND r.IsSpecialRate = 1
			LEFT JOIN general.[Date] td ON r.ToDateID = td.DateID  AND r.IsSpecialRate = 1
			LEFT JOIN currency.Price pA1 ON r.Adult1PriceID = pA1.PriceID
			LEFT JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID
			LEFT JOIN currency.Price pA2 ON r.Adult2PriceID = pA2.PriceID
			LEFT JOIN currency.Currency cA2 ON pA2.CurrencyID = cA2.CurrencyID
			LEFT JOIN currency.Price pA3 ON r.Adult3PriceID = pA3.PriceID
			LEFT JOIN currency.Currency cA3 ON pA3.CurrencyID = cA3.CurrencyID
			LEFT JOIN currency.Price pA4 ON r.Adult4PriceID = pA4.PriceID
			LEFT JOIN currency.Currency cA4 ON pA4.CurrencyID = cA4.CurrencyID
			LEFT JOIN currency.Price pEx ON r.ExtraAdultPriceID = pEx.PriceID
			LEFT JOIN currency.Currency cEX ON pEx.CurrencyID = cEX.CurrencyID
			LEFT JOIN currency.Price pCh ON r.ExtraChildPriceID = pCh.PriceID
			LEFT JOIN currency.Currency cCh ON pCh.CurrencyID = cCh.CurrencyID		
			WHERE r.LocationID = @LocationID 
			ORDER BY r.RateID DESC
		END
	ELSE
		BEGIN
			SELECT r.RateID
			,l.[LocationName]	
			,r.RateCode
			,d.Duration 'RateType'	
			,CASE WHEN r.RoomTypeID IS NULL THEN '-' ELSE rt.RoomType + ' (' + rt.Description + ')' END [RoomType]	
			,FORMAT(r.ActivationDate,'dd-MMM-yyyy') [ActivationDate]
			,ISNULL(FORMAT(fd.[Date],'dd-MMM-yyyy'),'') [FromDate]
			,ISNULL(FORMAT(td.[Date],'dd-MMM-yyyy'),'') [ToDate]
			,CASE WHEN r.Adult1PriceID IS NOT NULL THEN cA1.CurrencySymbol + CAST(pA1.Rate as varchar) ELSE '-' END [RateFor1Adult] 
			,CASE WHEN r.Adult2PriceID IS NOT NULL THEN cA2.CurrencySymbol + CAST(pA2.Rate as varchar) ELSE '-' END [RateFor2Adult]
			,CASE WHEN r.Adult3PriceID IS NOT NULL THEN cA3.CurrencySymbol + CAST(pA3.Rate as varchar) ELSE '-' END [RateFor3Adult]
			,CASE WHEN r.Adult4PriceID IS NOT NULL THEN cA4.CurrencySymbol + CAST(pA4.Rate as varchar) ELSE '-' END [RateFor4Adult]
			,CASE WHEN r.ExtraAdultPriceID IS NOT NULL THEN cEx.CurrencySymbol + CAST(pEx.Rate as varchar) ELSE '-' END [RateForExtraAdult]
			,CASE WHEN r.ExtraChildPriceID IS NOT NULL THEN cCh.CurrencySymbol + CAST(pCh.Rate as varchar) ELSE '-' END [RatePerChild]  
			,r.Description [Description]
			,CASE WHEN r.IsActive = 0 THEN 'De-Activated' ELSE 'Activated' END Status
			,[Title] + ' ' + (SELECT dbo.fnPascalCase(FirstName)) + ' ' + (SELECT dbo.fnPascalCase(LastName)) AS  [User]
			FROM room.Rate r
			INNER JOIN room.RoomType rt ON r.RoomTypeID = rt.RoomTypeID	
			INNER JOIN general.Location l ON r.LocationID = l.LocationID		
			INNER JOIN reservation.Duration d ON r.DurationID = d.DurationID
			INNER JOIN [app].[User] u ON r.UserID = u.UserID
			INNER JOIN contact.Details cd ON u.ContactID = cd.ContactID
			LEFT JOIN [person].[Title] t ON cd.TitleID = t.TitleID	
			LEFT JOIN general.[Date] fd ON r.FromDateID = fd.DateID AND r.IsSpecialRate = 1
			LEFT JOIN general.[Date] td ON r.ToDateID = td.DateID  AND r.IsSpecialRate = 1
			LEFT JOIN currency.Price pA1 ON r.Adult1PriceID = pA1.PriceID
			LEFT JOIN currency.Currency cA1 ON pA1.CurrencyID = cA1.CurrencyID
			LEFT JOIN currency.Price pA2 ON r.Adult2PriceID = pA2.PriceID
			LEFT JOIN currency.Currency cA2 ON pA2.CurrencyID = cA2.CurrencyID
			LEFT JOIN currency.Price pA3 ON r.Adult3PriceID = pA3.PriceID
			LEFT JOIN currency.Currency cA3 ON pA3.CurrencyID = cA3.CurrencyID
			LEFT JOIN currency.Price pA4 ON r.Adult4PriceID = pA4.PriceID
			LEFT JOIN currency.Currency cA4 ON pA4.CurrencyID = cA4.CurrencyID
			LEFT JOIN currency.Price pEx ON r.ExtraAdultPriceID = pEx.PriceID
			LEFT JOIN currency.Currency cEX ON pEx.CurrencyID = cEX.CurrencyID
			LEFT JOIN currency.Price pCh ON r.ExtraChildPriceID = pCh.PriceID
			LEFT JOIN currency.Currency cCh ON pCh.CurrencyID = cCh.CurrencyID		
			WHERE r.LocationID = @LocationID AND r.RoomTypeID = @RoomTypeID
			ORDER BY r.RateID DESC
		END
END


