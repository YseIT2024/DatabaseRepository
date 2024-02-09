
CREATE PROCEDURE [report].[spGetReportSequenceNo] 
(   
    @DocTypeId INT,
    @SequenceNo VARCHAR(255) OUTPUT
)
AS   
BEGIN
    
        UPDATE report.ReportConfiguration
        SET DocSeq = DocSeq + 1
        WHERE DocumentTypeId = @DocTypeId AND IsActive = 1;

        SET @SequenceNo = (
            SELECT CONCAT(Prefix, '', PostFix, '', CONVERT(NVARCHAR, FORMAT(DocSeq, '000000'), 100))
            FROM report.ReportConfiguration
            WHERE DocumentTypeId = @DocTypeId AND IsActive = 1
        );

       
END


 