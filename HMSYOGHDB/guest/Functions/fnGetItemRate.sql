
CREATE FUNCTION [guest].[fnGetItemRate]
(	
	@ItemID INT,
	@CompanyId INT,
	@SDate DATE,
	@Type INT

)
--RETURNS @Output TABLE([TotalAmount] decimal(18,6), [Complimentary] decimal(18,6), [VoidAmount] decimal(18,6), [PayableAmount] decimal(18,6), [Discount] decimal(18,6)
--                      ,[AdvancePay] decimal(18,6), [OtherPayment] decimal(18,6),[TotalPayment] decimal(18,6),[Balance] decimal(18,6)) 
RETURNS DECIMAL

AS
BEGIN
	--DECLARE @NetRate DECIMAL;
	--DECLARE @SellRate DECIMAL;
	--DECLARE @Discount DECIMAL;
	DECLARE @Result DECIMAL;

	IF @Type=1
	
	SELECT @Result= NetRate FROM [guest].[GuestCompanyRateContract] 
	WHERE GuestCompanyID=@CompanyId AND ItemID=@ItemID AND @SDate BETWEEN contractfrom AND ContractTo 
	AND IsActive=1
	ELSE IF @Type=2
	SELECT @Result= SellRate FROM [guest].[GuestCompanyRateContract] 
	WHERE GuestCompanyID=@CompanyId AND ItemID=@ItemID AND @SDate BETWEEN contractfrom AND ContractTo
	AND IsActive=1
	ELSE IF @Type=3
	SELECT @Result= DiscountPercent FROM [guest].[GuestCompanyRateContract] 
	WHERE GuestCompanyID=@CompanyId AND ItemID=@ItemID AND @SDate BETWEEN contractfrom AND ContractTo
	AND IsActive=1
		
	RETURN @Result
END
