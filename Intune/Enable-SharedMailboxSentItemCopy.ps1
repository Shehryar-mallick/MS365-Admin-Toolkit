param(
    [Parameter(Mandatory = $true)]
    [string]$AdminEmail,

    [Parameter(Mandatory = $true)]
    [string]$MailboxEmail
)

$ErrorActionPreference = "Stop"

try {
    Write-Host "Importing Exchange Online module..." -ForegroundColor Cyan
    Import-Module ExchangeOnlineManagement

    Write-Host "Connecting to Exchange Online..." -ForegroundColor Cyan
    Connect-ExchangeOnline -UserPrincipalName $AdminEmail -ShowBanner:$false

    Write-Host "Enabling sent item copy settings for $MailboxEmail ..." -ForegroundColor Yellow
    Set-Mailbox -Identity $MailboxEmail -MessageCopyForSentAsEnabled $true
    Set-Mailbox -Identity $MailboxEmail -MessageCopyForSendOnBehalfEnabled $true

    Write-Host ""
    Write-Host "Verifying mailbox settings..." -ForegroundColor Green
    Get-Mailbox -Identity $MailboxEmail |
        Format-List DisplayName,PrimarySmtpAddress,MessageCopyForSentAsEnabled,MessageCopyForSendOnBehalfEnabled
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
        # Ignore disconnect errors
    }
}