# utf-8
function Get-tptCentreonServices {
    <#
    .SYNOPSIS
        Obtiene un inventario de servicios desde el API REST de Centreon.

    .DESCRIPTION
        Llama al endpoint listServices del API REST de Centreon para recuperar servicios.
        Aplica filtros opcionales por nombre de host con soporte para wildcards.
        Guarda el token de autenticación desde $script:CentreonToken y lo usa para la solicitud.
        Devuelve un array de objetos PSCustomObject con detalles del servicio.

    .PARAMETER Name
        Array opcional de nombres de servicios a devolver. Permite wildcards (por ejemplo, 'svc*').
        Si está vacío, devuelve todos los servicios.

    .PARAMETER HostName
        Nombre opcional de host para filtrar servicios por host. PROHIBIDO usar -Host como parámetro.

    .EXAMPLE
        Get-tptCentreonServices
        Devuelve todos los servicios de Centreon usando el token autenticado guardado.

    .EXAMPLE
        Get-tptCentreonServices -Name '*mysql*'
        Devuelve servicios con 'mysql' en el nombre.

    .EXAMPLE
        Get-tptCentreonServices -HostName 'web-server-01'
        Devuelve servicios asociados con el host web-server-01.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Id, Name, Host, State, LastCheck.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [string[]]$Name = @(),

        [string]$HostName = $null
    )

    if (-not $script:CentreonToken) {
        throw 'No hay conexión autenticada con Centreon. Llama a Connect-tptCentreon primero.'
    }

    # Preparar parámetros para listServices
    $params = @{
        action = "listServices"
        params = @{
            page = 1
            count = 1000
        }
    }

    if ($HostName) {
        $params.params.hostName = $HostName
    }

    $body = $params | ConvertTo-Json -Depth 4

    $headers = @{
        'X-Auth-Token' = $script:CentreonToken
        'Authorization' = "Bearer $($script:CentreonToken)"
    }

    $response = Invoke-RestMethod -Method POST -Uri "$($script:CentreonUrl)/api.php" -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 30

    # Procesar respuesta
    $services = @()
    if ($response.result?.data) {
        foreach ($svcData in $response.result.data) {
            [PSCustomObject]@{
                Id = $svcData.id
                Name = $svcData.name
                Host = $svcData.hostName
                State = $svcData.status?.label ?? $svcData.status
                LastCheck = $svcData.lastCheck
            }
        }
    }

    # Filtrar por nombre si se especificó
    if ($Name) {
        $filteredServices = foreach ($service in $services) {
            foreach ($pattern in $Name) {
                if ($service.Name -like $pattern) {
                    $service
                    break
                }
            }
        }
        $services = $filteredServices
    }

    $services
}