CREATE FUNCTION [dbo].[GetDatetimeBasedonTimezone]

(
	@DatetoCheck Datetime 
	--@ClientID int
)

RETURNS varchar(17)

AS

BEGIN
	declare @TimeZone decimal
	DECLARE @ClientDateTime datetime
	declare @DateFormatted varchar(17)
	select @TimeZone = -3
	select @ClientDateTime=SWITCHOFFSET(CONVERT(DATETIMEOFFSET, @DatetoCheck), @Timezone*60)
	select @DateFormatted = Replace(convert(varchar(11),@ClientDateTime,106),' ','-')+' '+Convert(varchar(5),@ClientDateTime,108)
	return @DateFormatted
END
