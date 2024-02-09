CREATE Proc  [reservation].[spGetProcessType]
AS
Begin
SELECT TOP 1000 [ProcessTypeId]
      ,[ProcessType]
     -- ,[IsActive]
  FROM [HMSYOGH].[reservation].[ProcessType]
  Where IsActive=1

End
