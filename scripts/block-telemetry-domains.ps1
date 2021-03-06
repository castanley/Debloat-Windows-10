#   Description:
# This script blocks telemetry related domains via the hosts file and related
# IPs via Windows Firewall.

echo "Adding telemetry domains to hosts file"
$hosts = cat "$PSScriptRoot\..\res\telemetry-hosts.txt"
$hosts_file = "$env:systemroot\System32\drivers\etc\hosts"
[ipaddress[]] $ips = @()
foreach ($h in $hosts) {
    try {
        # store for next part
        $ips += [ipaddress]$h
    } catch [System.InvalidCastException] {
        $contaisHost = Select-String -Path $hosts_file -Pattern $h
        If (-Not $contaisHost) {
            # can be redirected by hosts
            echo "0.0.0.0 $h" | Out-File -Encoding ASCII -Append $hosts_file
        }
    }
}

echo "Adding telemetry ips to firewall"
Remove-NetFirewallRule -DisplayName "Block Telemetry IPs" -ErrorAction SilentlyContinue
New-NetFirewallRule -DisplayName "Block Telemetry IPs" -Direction Outbound `
    -Action Block -RemoteAddress ([string[]]$ips)
