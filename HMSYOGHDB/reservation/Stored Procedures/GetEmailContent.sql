
CREATE PROCEDURE [reservation].[GetEmailContent]
(	
	@EmailTypeID int 
)
AS
BEGIN
	SET NOCOUNT ON;	
	

	select top 1(EmailContent) EmailContent from [reservation].[Email] where EmailTypeID = @EmailTypeID
END
