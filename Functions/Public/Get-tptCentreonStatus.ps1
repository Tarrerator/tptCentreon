# utf-8
function Get-tptCentreonStatus {
    <#
    .SYNOPSIS
        Devuelve el estado actual de conexión y versión de la API REST de Centreon.

    .DESCRIPTION
        Consulta el estado de la conexión autenticada con Centreon. Devuelve un objeto
        PSCustomObject con el URL base, si está conectado y la versión de la API.
        Si no hay conexión autenticada ($script:CentreonToken), indica que no hay conexión.

    .EXAMPLE
        Get-tptCentreonStatus
        Devuelve el estado de conexión actual con Centreon.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Url, Connected, ApiVersion.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param()

    $connected = (-not [string]::IsNullOrEmpty($script:CentreonToken))

    [PSCustomObject]@{
        Url = $script:CentreonUrl ?? "(no configurado)"
        Connected = $connected
        ApiVersion = if ($connected) { '1.0' } else { $null }
    }
}