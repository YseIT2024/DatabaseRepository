
CREATE PROCEDURE [fund].[spGetFundTransferHistory]
(
	@DrawerID int,
	@FromDate date,
	@ToDate date
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;	

	SELECT [FundFlowID]      
	,ft.FundType
	,ffd.FundFlowDirectionID
	,ffd.FundFlowDirection
	,CASE WHEN ff.FundFlowDirectionID = 1 OR ff.FundFlowDirectionID = 4 THEN fromHotel.LocationCode ELSE fromCasino.CasinoCode END [FromLocation]
	,CASE WHEN ff.FundFlowDirectionID = 1 OR ff.FundFlowDirectionID = 4 THEN toCasino.CasinoCode ELSE toHotel.LocationCode END [ToLocation]	
	,[USDAmount]
	,[SRDAmount]
	,[EURAmount]
	,ISNULL([SealbagNumber],'')[SealbagNumber]
	,ISNULL(TransactionID,0) TransactionID	
	,d.Drawer
	,FORMAT(ad.AccountingDate,'dd-MMM-yyyy') [AccountingDate]
	,FORMAT([DateTime],'dd-MMM-yyyy hh:mm tt')[DateTime]
	,ff.FundFlowStatusID
	,fs.FundFlowStatus
	,ISNULL(t.Title + ' ','') + cd.FirstName + ISNULL(' ' + cd.LastName,'') [TransferBy]      
	,[Remarks]
	FROM [fund].[Flow] ff
	INNER JOIN fund.[Type] ft ON ff.FundTypeID = ft.FundTypeID
	INNER JOIN fund.FundFlowDirection ffd ON ff.FundFlowDirectionID = ffd.FundFlowDirectionID
	INNER JOIN fund.FlowStatus fs ON ff.FundFlowStatusID = fs.FundFlowStatusID
	INNER JOIN app.Drawer d ON ff.DrawerID = d.DrawerID
	INNER JOIN account.AccountingDates ad ON ff.AccountingDateID = ad.AccountingDateId
	LEFT JOIN app.[User] u ON ff.UserID = u.UserID
	LEFT JOIN contact.Details cd ON u.ContactID = cd.ContactID
	LEFT JOIN person.Title t ON cd.TitleID = t.TitleID
	LEFT JOIN general.[Location] fromHotel ON ff.FlowFromID = fromHotel.LocationID
	LEFT JOIN company.Casino fromCasino ON ff.FlowFromID = fromCasino.CasinoID
	LEFT JOIN general.[Location] toHotel ON ff.FlowToID = toHotel.LocationID	
	LEFT JOIN company.Casino toCasino ON ff.FlowToID = toCasino.CasinoID
	WHERE ff.DrawerID = @DrawerID AND ad.AccountingDate BETWEEN @FromDate AND @ToDate
	ORDER BY FundFlowID DESC
END



