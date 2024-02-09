CREATE PROCEDURE [guest].[spGetCompanyInvoiceStatementDetails]    --'11/19/2023','12/20/2023',1,75 
(
    @FromDate date=null,
    @ToDate date=null,
	@userID INT=0 ,
	@locationID INT=0
)
AS
BEGIN
	SET NOCOUNT ON;
    
    SELECT 
        ISNULL(gci.CISID, 0) AS CISID,
        ISNULL(gcc.CompanyID, 0) AS CompanyID,
        ISNULL(gcc.CompanyName, '') AS CompanyName,
	    CONVERT(NVARCHAR(11), gci.CISFromDate, 106) AS CISFromDate,
	    CONVERT(NVARCHAR(11), gci.CISToDate, 106) AS CISToDate,
        --ISNULL(gci.TotalAmtBeforeTax, 0) AS TotalAmtBeforeTax,
        --ISNULL(gci.[Total Tax], 0) AS TotalTax,
        --ISNULL(gci.TotalAmt, 0) AS TotalAmt,
		FORMAT(gci.TotalAmtBeforeTax, 'N2') AS TotalAmtBeforeTax,
        FORMAT(gci.[Total Tax], 'N2') AS TotalTax,
        FORMAT(gci.TotalAmt, 'N2') AS TotalAmt,
	    CONVERT(NVARCHAR(11), gci.CreatedOn, 106) AS CreatedOn,
        ISNULL(gci.CreatedBy, 0) AS CreatedBy,
		ISNULL(gci.CISStatusID,0)AS CISStatusID,
		Case When ISNULL(gci.CISStatusID,0)=1 Then 'Pending'
			 when ISNULL(gci.CISStatusID,0)=0 Then 'Received' End AS CISStatus
       -- ISNULL(gcs.InvoiceNo, '') AS InvoiceNo
		
    FROM [guest].[CompanyInvoiceStatement] gci
    INNER JOIN guest.GuestCompany gcc ON gci.GuestCompanyID = gcc.CompanyID
   -- LEFT JOIN [guest].CompanyInvoiceStatementDetails gcs ON gci.CISID = gcs.CISID
   WHERE CAST(gci.CreatedOn AS date) BETWEEN @FromDate AND @ToDate --AND gci.CreatedOn IS not null

END



