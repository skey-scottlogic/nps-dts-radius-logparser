# Log parser for MS NPS dts RADIUS logs
# v 0.0.2 / 20180328
# Author: Simon Key <skey@scottlogic.com>

# PS C:\Windows\System32\LogFiles\NPS> .\nps-dts-radius-logparser.ps1 .\iaslog47.log | ? { $_.ClientFriendlyName -eq "NET_NCS" -and $_.SamAccountName -like "*manbearpig*" }

param (
    [string]$log = "C:\Windows\System32\LogFiles\" + (Get-ChildItem -Path "C:\Windows\System32\LogFiles" -File iaslog*.log | Sort-Object LastAccessTime -Descending | Select-Object -First 1),
    [int]$tail = 1000,
    [switch]$follow = $false,
    [switch]$l = $false
)

$packetTypes = @{
    1 = "Access-Request";
    2 = "Access-Accept";
    3 = "Access-Reject";
    4 = "Accounting-Request";
}

$reasonCodes = @{
    0 = "IAS_SUCCESS";
    1 = "IAS_INTERNAL_ERROR";
    2 = "IAS_ACCESS_DENIED";
    3 = "IAS_MALFORMED_REQUEST";
    4 = "IAS_GLOBAL_CATALOG_UNAVAILABLE";
    5 = "IAS_DOMAIN_UNAVAILABLE";
    6 = "IAS_SERVER_UNAVAILABLE";
    7 = "IAS_NO_SUCH_DOMAIN";
    8 = "IAS_NO_SUCH_USER";
    16 = "IAS_AUTH_FAILURE";
    17 = "IAS_CHANGE_PASSWORD_FAILURE";
    18 = "IAS_UNSUPPORTED_AUTH_TYPE";
    32 = "IAS_LOCAL_USERS_ONLY";
    33 = "IAS_PASSWORD_MUST_CHANGE";
    34 = "IAS_ACCOUNT_DISABLED";
    35 = "IAS_ACCOUNT_EXPIRED";
    36 = "IAS_ACCOUNT_LOCKED_OUT";
    37 = "IAS_INVALID_LOGON_HOURS";
    38 = "IAS_ACCOUNT_RESTRICTION";
    48 = "IAS_NO_POLICY_MATCH";
    64 = "IAS_DIALIN_LOCKED_OUT";
    65 = "IAS_DIALIN_DISABLED";
    66 = "IAS_INVALID_AUTH_TYPE";
    67 = "IAS_INVALID_CALLING_STATION";
    68 = "IAS_INVALID_DIALIN_HOURS";
    69 = "IAS_INVALID_CALLED_STATION";
    70 = "IAS_INVALID_PORT_TYPE";
    71 = "IAS_INVALID_RESTRICTION";
    80 = "IAS_NO_RECORD";
    96 = "IAS_SESSION_TIMEOUT";
    97 = "IAS_UNEXPECTED_REQUEST";
}

[string[]]$DefaultProperties = "Timestamp","NPPolicyName","ProxyPolicyName","UserName","ClientFriendlyName","SAMAccountName","PacketTypeName","ReasonCodeName"
$ddps = New-Object System.Management.Automation.PSPropertySet DefaultDisplayPropertySet, $DefaultProperties
$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]$ddps

Function line ($logline) {
    $l = [pscustomobject]@{
        Timestamp           = $logline.Timestamp."#text"
        ComputerName        = $logline."Computer-Name"."#text"
        NPPolicyName        = $logline."NP-Policy-Name"."#text"
        ProxyPolicyName     = $logline."Proxy-Policy-Name"."#text"
        EventSource         = $logline."Event-Source"."#text"
        UserName            = $logline."User-Name"."#text"
        ClientIPAddress     = $logline."Client-IP-Address"."#text"
        ClientVendor        = $logline."Client-Vendor"."#text"
        ClientFriendlyName  = $logline."Client-Friendly-Name"."#text"
        SAMAccountName      = $logline."SAM-Account-Name"."#text"
        PacketType          = $logline."Packet-Type"."#text"
        PacketTypeName      = $packetTypes[[int]$logline."Packet-Type"."#text"]
        ReasonCode          = $logline."Reason-Code"."#text"
        ReasonCodeName      = $reasonCodes[[int]$logline."Reason-Code"."#text"]
    }
    Add-Member -InputObject $l -MemberType MemberSet -Name PSStandardMembers -Value $PSStandardMembers
    return $l
}

if ($l) {
    Get-Content $log -Tail $tail -Wait:$follow | % { line(([xml]$_).Event) } | fl
} else {
    Get-Content $log -Tail $tail -Wait:$follow | % { line(([xml]$_).Event) } | ft
}
