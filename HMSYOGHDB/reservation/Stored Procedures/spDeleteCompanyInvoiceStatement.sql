-- =============================================
-- Author:		VASANTHAKUMAR
-- Create date: 18-12-2023
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[spDeleteCompanyInvoiceStatement]
(
@CISID INT
)
AS
BEGIN

DECLARE @IsSuccess bit = 0;
DECLARE @Message varchar(max) = '';
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	delete guest.CompanyInvoiceStatementDetails  where  CISID=@CISID 
    delete guest.CompanyInvoiceStatement where  CISID=@CISID

	
SET @IsSuccess = 1; 				
SET @Message = 'Company Invoice Statement Deleted Successfully' ;

select @IsSuccess as IsSuccess,@Message as Message
END
