# utf-8
function Get-tptCentreonMetrics {
    <#
    .SYNOPSIS
        Obtiene métricas desde el API REST de Centreon para un host específico.

    .DESCRIPTION
        Llama al endpoint listMetrics (o query de métricas) del API REST de Centreon
        para recuperar métricas para el host dado. Aplica filtros opcionales por nombre de métrica
        con soporte para wildcards. Guarda el token de autenticación desde $script:CentreonToken
        y lo usa para la solicitud. Devuelve un array de objetos PSCustomObject con valores de métricas.

    .PARAMETER HostName
        Nombre del host para obtener sus métricas (requerido).

    .PARAMETER MetricName
        Array opcional de nombres de métricas a devolver. Permite wildcards (por ejemplo, '*cpu*').
        Si está vacío, devuelve todas las métricas para el host.

    .EXAMPLE
        Get-tptCentreonMetrics -HostName 'web-server-01'
        Devuelve todas las métricas para el host web-server-01.

    .EXAMPLE
        Get-tptCentreonMetrics -HostName 'db-server' -MetricName '*memory*'
        Devuelve solo métricas de memoria para el host db-server.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Host, Metric, Value, Unit, Timestamp.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [string]$HostName,

        [string[]]$MetricName = @()
    )

    if (-not $script:CentreonToken) {
        throw 'No hay conexión autenticada con Centreon. Llama a Connect-tptCentreon primero.'
    }

    # Preparar parámetros para listMetrics
    $params = @{
        action = "listMetrics"
        params = @{
            hostName = $HostName
            page = 1
            count = 1000
        }
    }

    if ($MetricName) {
        $params.params.search = $MetricName[0]
    }

    $body = $params | ConvertTo-Json -Depth 4

    $headers = @{
        'X-Auth-Token' = $script:CentreonToken
        'Authorization' = "Bearer $($script:CentreonToken)"
    }

    $response = Invoke-RestMethod -Method POST -Uri "$($script:CentreonUrl)/api.php" -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 30

    # Procesar respuesta
    $metrics = @()
    if ($response.result?.data) {
        foreach ($metricData in $response.result.data) {
            [PSCustomObject]@{
                Host = $metricData.hostName
                Metric = $metricData.metricName
                Value = $metricData.value
                Unit = $metricData.unit
                Timestamp = $metricData.timestamp
            }
        }
    }

    # Filtrar por nombre de métrica si se especificó
    if ($MetricName) {
        $filteredMetrics = foreach ($metric in $metrics) {
            foreach ($pattern in $MetricName) {
                if ($metric.Metric -like $pattern) {
                    $metric
                    break
                }
            }
        }
        $metrics = $filteredMetrics
    }

    $metrics
}