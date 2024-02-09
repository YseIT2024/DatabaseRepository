
CREATE PROCEDURE [fund].[spGetPendingTransferFunds] --2,2,4,3,5
(
	@FundFlowDirectionID INT,
	@FundFlowStatusID INT,
	@FundChangeDirectionID INT,
	@ConfirmFundChangeDirectionID INT,
	@DrawerID INT = NULL	
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE	@LocationID int = (SELECT LocationID FROM app.Drawer WHERE DrawerID = @DrawerID);
	
	IF(@DrawerID IS NULL) -- For CMS App
		BEGIN
			----------------- 1. Funds From Hotel ------------------------	
			SELECT FundFlowID
			,hotel.LocationCode [Location]
			,USDAmount
			,SRDAmount
			,EURAmount
			,SealbagNumber
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId
			INNER JOIN general.[Location] hotel ON ff.FlowFromID = hotel.LocationID			
			WHERE FundFlowDirectionID = @FundFlowDirectionID AND FundFlowStatusID = @FundFlowStatusID
			AND ParentFundFlowID IS NULL
			
			--------------- 2. Change To Hotel ---------------------------------
			SELECT FundFlowID
			,hotel.LocationCode [Location]
			,USDAmount
			,SRDAmount
			,EURAmount	
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId
			INNER JOIN general.[Location] hotel ON ff.FlowToID = hotel.LocationID			
			WHERE FundFlowDirectionID = @FundChangeDirectionID AND FundFlowStatusID = 5
			AND ParentFundFlowID IS NOT NULL

			SELECT ff.FundFlowID
			,fp.PettyCashID
			FROM [fund].[Flow] ff
			INNER JOIN fund.FlowAndPettyCash fp ON ff.FundFlowID = fp.FundFlowID
			WHERE FundFlowDirectionID = @FundChangeDirectionID AND FundFlowStatusID = 5
			AND ParentFundFlowID IS NOT NULL

			-------------------- 3. Needs to confirm Pending Transfer Fund Changes ---------------
			SELECT FundFlowID
			,CASE WHEN ff.FundFlowDirectionID = 4 THEN hotel.LocationCode ELSE casino.CasinoCode END [Location]
			,USDAmount
			,SRDAmount
			,EURAmount	
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId
			INNER JOIN general.[Location] hotel ON ff.FlowFromID = hotel.LocationID
			INNER JOIN company.Casino casino ON ff.FlowFromID = casino.CasinoID
			WHERE FundFlowDirectionID = @ConfirmFundChangeDirectionID AND FundFlowStatusID = 7
			AND ParentFundFlowID IS NOT NULL

			SELECT ff.FundFlowID
			,fp.PettyCashID
			FROM [fund].[Flow] ff
			INNER JOIN fund.FlowAndPettyCash fp ON ff.FundFlowID = fp.FundFlowID
			WHERE FundFlowDirectionID = @ConfirmFundChangeDirectionID AND FundFlowStatusID = 7
			AND ParentFundFlowID IS NOT NULL
		END
	ELSE ---- For Hotel App
		BEGIN
			----------------- 1. Fund From Casino ------------------------	
			SELECT FundFlowID
			,casino.CasinoCode [Location]
			,USDAmount
			,SRDAmount
			,EURAmount
			,SealbagNumber
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId
			INNER JOIN company.Casino casino ON ff.FlowFromID = casino.CasinoID
			WHERE FF.FlowToID = @LocationID
			AND FundFlowDirectionID = @FundFlowDirectionID AND FundFlowStatusID = @FundFlowStatusID 
			AND ParentFundFlowID IS NULL

			--------------- 2. Change To Casino ---------------------------------
			SELECT FundFlowID
			,casino.CasinoCode [Location]
			,USDAmount
			,SRDAmount
			,EURAmount	
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId
			INNER JOIN company.Casino casino ON ff.FlowToID = casino.CasinoID
			WHERE FlowFromID = @LocationID 
			AND FundFlowDirectionID = @FundChangeDirectionID AND FundFlowStatusID = 5
			AND ParentFundFlowID IS NOT NULL

			SELECT ff.FundFlowID
			,fp.PettyCashID
			FROM [fund].[Flow] ff
			INNER JOIN fund.FlowAndPettyCash fp ON ff.FundFlowID = fp.FundFlowID		
			WHERE FundFlowDirectionID = @FundChangeDirectionID AND FundFlowStatusID = 5
			AND ParentFundFlowID IS NOT NULL

			-------------------- 3. Change From Casino ---------------
			SELECT FundFlowID
			,casino.CasinoCode [Location]
			,USDAmount
			,SRDAmount
			,EURAmount	
			,AccountingDate 
			FROM [fund].[Flow] ff
			INNER JOIN account.AccountingDates a ON ff.AccountingDateID = a.AccountingDateId			
			INNER JOIN company.Casino casino ON ff.FlowFromID = casino.CasinoID
			WHERE FlowToID = @LocationID 
			AND FundFlowDirectionID = @ConfirmFundChangeDirectionID AND FundFlowStatusID = 7
			AND ParentFundFlowID IS NOT NULL
		END
END



