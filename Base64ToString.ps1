
<#
.SYNOPSIS
Nishang script which decodes a base64 string to readable.

.DESCRIPTION
This payload decodes a base64 string to readable.

.PARAMETER Base64Str
The string to be decoded

.EXAMPLE
PS > Base64ToString "c3RhcnQtcHJvY2VzcyBjYWxjLmV4ZQ=="

.LINK
http://labofapenetrationtester.blogspot.com/
http://code.google.com/p/nishang
#>



Param( [Parameter(Position = 0, Mandatory = $True)] [String] $Base64Str)
function Base64ToString
{

  $base64string  = [System.Convert]::FromBase64String($Base64Str)
  $decodedstring = [System.Text.Encoding]::UTF8.GetString($base64string)
  $decodedstring
  }
Base64ToString