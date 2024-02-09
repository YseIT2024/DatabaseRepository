CREATE PROCEDURE [guest].[GetGuestMatesIDDocDetails] --1,1,1
(		
	@UserId int	,
	@ReservationID int,
	@GuestMatesID int
)
AS
BEGIN
	
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;
	
		SELECT RD.[DocumentTypeId], RD.[DocumentType],RD.[IsMandatory], DU.[DocumentId], DU.[DocumentURL],DU.DocumentImage,DU.DocumentContent
		FROM [reservation].[ReservationDocumentType] RD
		LEFT JOIN [reservation].[ReservationDocumentUpload] DU ON RD.[DocumentTypeId] = DU.[DocumentTypeId] 
			AND DU.[ReservationID] = @ReservationID AND DU.[GuestMatesID] = @GuestMatesID
			where RD.IsActive=1
		
END	