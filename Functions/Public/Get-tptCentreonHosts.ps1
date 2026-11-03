# utf-8
function Get-tptCentreonHosts {
    <#
    .SYNOPSIS
        Obtiene un inventario de hosts desde el API REST de Centreon.

    .DESCRIPTION
        Llama al endpoint listHosts del API REST de Centreon para recuperar hosts conectados.
        Aplica filtros opcionales por nombre con soporte para wildcards. Guarda el token de
        autenticación desde $script:CentreonToken y lo usa para la solicitud. Devuelve
        un array de objetos PSCustomObject con detalles del host.

    .PARAMETER Name
        Array opcional de nombres de hosts a devolver. Permite wildcards (por ejemplo, 'host*', '*host').
        Si está vacío, devuelve todos los hosts.

    .EXAMPLE
        Get-tptCentreonHosts
        Devuelve todos los hosts de Centreon usando el token autenticado guardado.

    .EXAMPLE
        Get-tptCentreonHosts -Name 'server-*'
        Devuelve hosts cuyo nombre comience con 'server-'.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Id, Name, Alias, State, LastCheck.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [string[]]$Name = @()
    )

    if (-not $script:CentreonToken) {
        throw 'No hay conexión autenticada con Centreon. Llama a Connect-tptCentreon primero.'
    }

    # Preparar parámetros para listHosts
    $params = @{
        action = "listHosts"
        params = @{
            page = 1
            count = 1000
            search = $null
        }
    }

    if ($Name) {
        $params.params.search = $Name[0]
    }

    $body = $params | ConvertTo-Json -Depth 4

    $headers = @{
        'X-Auth-Token' = $script:CentreonToken
        'Authorization' = "Bearer $($script:CentreonToken)"
    }

    $response = Invoke-RestMethod -Method POST -Uri "$($script:CentreonUrl)/api.php" -Headers $headers -Body $body -ContentType 'application/json' -TimeoutSec 30

    # Procesar respuesta
    $hosts = @()
    if ($response.result?.data) {
        foreach ($hostData in $response.result.data) {
            [PSCustomObject]@{
                Id = $hostData.id
                Name = $hostData.name
                Alias = $hostData.alias
                State = $hostData.status?.label ?? $hostData.status
                LastCheck = $hostData.lastCheck
            }
        }
    }

    # Filtrar por nombre si se especificó
    if ($Name) {
        $filteredHosts = foreach ($item in $hosts) {
            foreach ($pattern in $Name) {
                if ($item.Name -like $pattern) {
                    $item
                    break
                }
            }
        }
        $hosts = $filteredHosts
    }

    $hosts
}