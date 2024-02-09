
CREATE FUNCTION [reservation].[fnGetResrvationApprovalPending] 
(	
	@ReservationId int	
)
RETURNS varchar(255)
AS	
BEGIN
	declare @strRoom varchar(255);

	SELECT @strRoom = COALESCE(@strRoom + ',', '') + pt.ProcessType
	FROM [reservation].[ApprovalLog] al 
	inner join reservation.ProcessType pt on al.ProcessTypeId=pt.ProcessTypeId WHERE al.ProcesstypeId IN (1,2,5,6,7) 
	and al.ApprovalStatus=0 AND al.RefrenceNo=@ReservationId

	RETURN @strRoom;
END
