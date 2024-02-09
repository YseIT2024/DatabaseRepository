
 
CREATE  PROCEDURE [guest].[Usp_InsertOTAServices]
    @OTAServicesData AS [guest].[OTAServicesType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
	
	DECLARE @ReservationID INT;
	DECLARE @GuestID INT;
	DECLARE @Type nvarchar(50);
    -- Extract ReservationID from the @OTAServicesData table
    SELECT TOP 1 @ReservationID = [ReservationID], @GuestID = [GuestID],@Type=[Type] FROM @OTAServicesData;
	 

    -- Check if the ReservationID already exists
    IF EXISTS (SELECT 1 FROM [guest].[OTAServices] WHERE [ReservationID] = @ReservationID)
    BEGIN
        -- Delete existing records with the same ReservationID
        DELETE FROM [guest].[OTAServices] WHERE [ReservationID]=@ReservationID and GuestID_CompanyID=@GuestID;
    END

    INSERT INTO [guest].[OTAServices] ([ReservationID], [GuestID_CompanyID], [ServiceID], ServicePercent,ReservationTypeID,[Type])
    SELECT [ReservationID], [GuestID], [ServiceID], [SericePercent],ReservationTypeID,[Type]
    FROM @OTAServicesData;

	DECLARE @TotalAffectedRows INT = @@ROWCOUNT;


DECLARE @OutputSequenceNo VARCHAR(255);
--SET @AUTOID=(SELECT ISNULL(MAX(ProformaInvoiceId),1) FROM  [reservation].[ProformaInvoice])
EXEC [report].spGetReportSequenceNo @DocTypeId = 2, @SequenceNo = @OutputSequenceNo OUTPUT;


	IF(not exists (select * from [reservation].[ProformaInvoice] where ReservationId=@ReservationId and DocumentTypeId=2 and [Guest_CompanyId]=@GuestID and [Type]=@Type))
	BEGIN
		INSERT INTO [reservation].[ProformaInvoice](
		[DocumentTypeId]
		,[ReservationId]
		,[ProformaInvoiceNo]
		,[CreatedDate]
		,[CreatedBy]
		,[Guest_CompanyId]
		,[Type]
		)
		VALUES
		(2,@ReservationId,@OutputSequenceNo,GETDATE(),null,@GuestID,@Type)

	END

    DECLARE @IsSuccess BIT;
    DECLARE @Message NVARCHAR(255);

    
    IF @TotalAffectedRows > 0
    BEGIN
        SET @IsSuccess = 1;
        SET @Message = 'Saved successfully.';
    END
    ELSE
    BEGIN
        SET @IsSuccess = 0;
        SET @Message = 'Not Saved';
    END
	       
    SELECT @IsSuccess AS IsSuccess, @Message AS Message;
END;


