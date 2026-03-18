param(
    [Parameter(Mandatory = $true)]
    [string]$UserEmail
)

$ErrorActionPreference = "Stop"

try {
    Write-Host "Checking Exchange Online module..." -ForegroundColor Cyan

    if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
        throw "ExchangeOnlineManagement module is not installed on this device."
    }

    Import-Module ExchangeOnlineManagement

    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
    Connect-ExchangeOnline -ShowBanner:$false

    Write-Host "Triggering Managed Folder Assistant for $UserEmail ..." -ForegroundColor Yellow
    Start-ManagedFolderAssistant -Identity $UserEmail

    Write-Host ""
    Write-Host "Primary mailbox statistics" -ForegroundColor Green
    Get-EXOMailboxStatistics -Identity $UserEmail |
        Format-List DisplayName,TotalItemSize,ItemCount

    Write-Host ""
    Write-Host "Archive mailbox statistics" -ForegroundColor Green
    try {
        Get-EXOMailboxStatistics -Identity $UserEmail -Archive |
            Format-List DisplayName,TotalItemSize,ItemCount
    }
    catch {
        Write-Warning "Archive mailbox statistics could not be retrieved. The archive may not be provisioned yet, or it may not be available yet for this mailbox."
    }
}
catch {
    Write-Host ""
    Write-Host "Script failed: $($_.Exception.Message)" -ForegroundColor Red
}
finally {
    try {
        Disconnect-ExchangeOnline -Confirm:$false
        Write-Host ""
        Write-Host "Disconnected from Exchange Online." -ForegroundColor Cyan
    }
    catch {
        # Do nothing if already disconnected
    }
}