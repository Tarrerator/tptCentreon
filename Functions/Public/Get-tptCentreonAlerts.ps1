# utf-8
function Get-tptCentreonAlerts {
    <#
    .SYNOPSIS
        Obtiene alertas desde el API REST de Centreon.

    .DESCRIPTION
        Llama al endpoint listAlerts (o similar) del API REST de Centreon para recuperar alertas.
        Aplica filtros opcionales por severidad (CRITICAL, WARNING, UNKNOWN) y límite.
        Guarda el token de autenticación desde $script:CentreonToken y lo usa para la solicitud.
        Devuelve un array de objetos PSCustomObject con detalles de alertas.

    .PARAMETER Severity
        Array opcional de niveles de severidad a devolver (CRITICAL, WARNING, UNKNOWN).
        Si está vacío, devuelve todas las alertas.

    .PARAMETER Limit
        Número máximo de alertas a devolver (50 por defecto).

    .EXAMPLE
        Get-tptCentreonAlerts
        Devuelve hasta 50 últimas alertas de Centreon.

    .EXAMPLE
        Get-tptCentreonAlerts -Severity 'CRITICAL','WARNING' -Limit 100
        Devuelve hasta 100 alertas con severidad crítica o de advertencia.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Id, Host, Service, Severity, Message, Timestamp.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [ValidateSet('CRITICAL', 'WARNING', 'UNKNOWN')]
        [string[]]$Severity = @(),

        [int]$Limit = 50
    )

    if (-not $script:CentreonToken) {
        throw 'No hay conexión autenticada con Centreon. Llama a Connect-tptCentreon primero.'
    }

    # Preparar parámetros para listAlerts
    $params = @{
        action = "listAlerts"
        params = @{
            page = 1
            count = $Limit
            severity = $null
        }
    }

    if ($Severity) {
        $params.params.severity = $Severity
    }

    $body = $params | ConvertTo-Json -Depth 4

    $headers = @{
        'X-Auth-Token' = $script:CentreonToken
        'Authorization' = "Bearer $($script:CentreonToken)"
    }

    $response = Invoke-RestMethod -Method POST -Uri "$($script:CentreonUrl)/api.php" -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 30

    # Procesar respuesta
    $alerts = @()
    if ($response.result?.data) {
        foreach ($alertData in $response.result.data) {
            [PSCustomObject]@{
                Id = $alertData.id
                Host = $alertData.hostName
                Service = $alertData.serviceName
                Severity = $alertData.severity
                Message = $alertData.message
                Timestamp = $alertData.timestamp
            }
        }
    }

    # Filtrar por severidad si se especificó
    if ($Severity) {
        $filteredAlerts = foreach ($alert in $alerts) {
            foreach ($sev in $Severity) {
                if ($alert.Severity -eq $sev) {
                    $alert
                    break
                }
            }
        }
        $alerts = $filteredAlerts
    }

    # Limitar al número solicitado
    if ($alerts.Count -gt $Limit) {
        $alerts = $alerts[0..($Limit - 1)]
    }

    $alerts
}