create PROCEDURE [guest].[usp_CreateCompanyInvoiceStatement]
    @CISID Int,
    @GuestCompanyID INT,
    @CISFromDate DATETIME,
    @CISToDate DATETIME,
    @TotalAmtBeforeTax  DECIMAL(18, 4),
    @TotalTax DECIMAL(18, 4),
    @TotalAfterTax DECIMAL(18, 4),
    @CreatedBy INT,
    @CreatedOn DATETIME,
    @LocationId INT,
	@CisStatusId INT,
	@dtCreateCompanyInvoiceStatement AS [guest].[dtCreateCompanyInvoiceStatement] READONLY
AS

BEGIN TRY
 BEGIN
    DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';

   BEGIN

			INSERT INTO guest.CompanyInvoiceStatement (GuestCompanyID, CISFromDate, CISToDate, TotalAmtBeforeTax, [Total Tax], TotalAmt, CreatedBy, CreatedOn, LocationId,CISStatusID)
			VALUES (@GuestCompanyID, @CISFromDate, @CISToDate, @TotalAmtBeforeTax, @TotalTax, @TotalAfterTax, @CreatedBy, @CreatedOn, @LocationId,@CisStatusId);

									
			  SET @CISID = SCOPE_IDENTITY();

			 INSERT INTO guest.CompanyInvoiceStatementDetails (CISID, InvoiceNo, TotalAmountBeforeTax, TotalTaxAmount, ServiceTaxAmount, TotalAmountAfterTax, AdditionalDiscount, RoundOffAmount, TotalAmountNet, CreatedBy,Created)
			                                           Select @CISID,[InvoiceNumber],TotalAmountBeforeTax,TotalTaxAmount,ServiceTaxAmount,TotalAmountAfterTax,AdditionalDiscount,RoundOffAmount,TotalAmountNet,@CreatedBy,Getdate()
													   From @dtCreateCompanyInvoiceStatement

						SET @IsSuccess = 1; --success
						SET @Message = 'Company/Corporate Invoice created successfully'
						End

       END
END TRY  
						
		BEGIN CATCH    
				IF (XACT_STATE() = -1) 
				BEGIN  			
					ROLLBACK TRANSACTION;  
					SET @Message = ERROR_MESSAGE();			
					SET @IsSuccess = 0; --error			
				END;    
    
				IF (XACT_STATE() = 1)  
				BEGIN  			
					COMMIT TRANSACTION;   
					SET @IsSuccess = 1; --success 
					IF(@CISID = 0)
					BEGIN 
						SET @Message = 'Company/Corporate Invoice created successfully.';
					END
					ELSE
					BEGIN
						SET @Message = 'Company/Corporate Invoice Updated successfully .';
					END
				END;  
		
				---------------------------- Insert into activity log---------------	
				DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
				EXEC [app].[spInsertActivityLog]28,@CISID,@Act,@CreatedBy	
			END CATCH;  

			SELECT @IsSuccess AS [IsSuccess], @Message AS [Message], @CISID as [CompanyID]


