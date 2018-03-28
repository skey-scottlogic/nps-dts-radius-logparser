Parser for MS NPS dts/xml RADIUS log files
==========================================

Simple parser for NPS log files.  Based on the work of Jochen Bartl <jochen.bartl@gmail.com>, from https://github.com/verbosemode/nps-dts-radius-logparser.

Parameters
----------

* log - log file to read (defaults to the newest iaslog*.log in C:\Windows\System32\LogFiles\)
* tail - number of lines to read (defaults to 100)
* follow - boolean, follow the log file

Usage Example
-------------

	PS > .\nps-dts-radius-logparser.ps1 | ft
	
	Timestamp               NPPolicyName ProxyPolicyName UserName                 ClientFriendlyName SAMAccountName   PacketTypeName ReasonCodeName
	---------               ------------ --------------- --------                 ------------------ --------------   -------------- --------------
	...
	03/28/2018 08:46:11.175 LAN          LAN             host/WS01043.example.com Wifi: wifi-f       EXAMPLE\WS01043$ Access-Request IAS_SUCCESS
	03/28/2018 08:46:11.175 LAN          LAN                                      Wifi: wifi-f       EXAMPLE\WS01043$                IAS_SUCCESS
	03/28/2018 08:46:11.769 Wired        Wired           host/WS00882.example.com Switch: sw-a       EXAMPLE\WS00882$ Access-Request IAS_SUCCESS
	03/28/2018 08:46:11.769 Wired        Wired                                    Switch: sw-a       EXAMPLE\WS00882$                IAS_SUCCESS
	03/28/2018 08:46:12.769 Wired        Wired           host/WS00123.example.com Switch: sw-a       EXAMPLE\WS00123$ Access-Request IAS_SUCCESS
	03/28/2018 08:46:12.769 Wired        Wired                                    Switch: sw-a       EXAMPLE\WS00123$                IAS_SUCCESS

	PS > .\nps-dts-radius-logparser.ps1 -follow | ? { $_.UserName -eq "host/WS00882.example.com" -and $_.ClientFriendlyName -like "Switch*" } | ft

	Timestamp               NPPolicyName ProxyPolicyName UserName                 ClientFriendlyName SAMAccountName   PacketTypeName ReasonCodeName
	---------               ------------ --------------- --------                 ------------------ --------------   -------------- --------------
	03/28/2018 08:46:11.769 Wired        Wired           host/WS00882.example.com Switch: sw-a       EXAMPLE\WS00882$ Access-Request IAS_SUCCESS
	03/28/2018 08:46:11.769 Wired        Wired                                    Switch: sw-a       EXAMPLE\WS00882$                IAS_SUCCESS
