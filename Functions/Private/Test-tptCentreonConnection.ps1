# utf-8
function Test-tptCentreonConnection {
    <#
    .SYNOPSIS
        Autentica contra el API REST de Centreon y devuelve un token válido.

    .DESCRIPTION
        Función privada. Ejecuta el endpoint de autenticación del API REST de Centreon
        (action="authenticate") y devuelve el authToken si es válido. Si no, lanza un
        error con el mensaje de error específico de la API.

    .PARAMETER Url
        URL base del servidor Centreon (incluir scheme y puerto).
        Si no se proporciona, usa $script:CentreonUrl si existe, o 'https://centreon.local:8080'.

    .PARAMETER Port
        Puerto del servidor Centreon (8080 por defecto). Se ignora si la URL contiene puerto.

    .PARAMETER Credential
        Credenciales de Centreon (usuario y contraseña). Se requieren para la autenticación.

    .OUTPUTS
        System.String que contiene el authToken para usar en llamadas posteriores.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [string]$Url = $null,

        [int]$Port = 8080,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCredential]$Credential
    )

    # Construir URL base
    if (-not $Url) {
        $Url = $script:CentreonUrl ?? "https://centreon.local:8080"
    }

    # Asegurar scheme y puerto correctos
    if (-not $Url.StartsWith("http")) {
        $Url = "https://$Url"
    }

    if ($Port -ne 8080 -and -not $Url.Contains(":$Port")) {
        $Url = $Url -replace "(:\d+)|$", ":$Port$"
    }

    # Preparar cuerpo de autenticación
    $authBody = @{
        action = 'authenticate'
        params = @{
            username = $Credential.UserName
            password = $Credential.GetNetworkCredential().Password
        }
    } | ConvertTo-Json -Depth 4

    try {
        $response = Invoke-RestMethod -Method POST -Uri "$Url/api.php" -Body $authBody -ContentType 'application/json' -TimeoutSec 30

        if ($response.authToken) {
            return $response.authToken
        }
        else {
            throw "Autenticación fallida: authToken no devuelto por el API. Respuesta: $(ConvertTo-Json $response)"
        }
    }
    catch {
        $errorMsg = if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.ReadToEnd() | ConvertFrom-Json -ErrorAction SilentlyContinue
        }
        $errorMsg

        if ($errorMsg.message) {
            throw "Error de autenticación Centreon: $($errorMsg.message)"
        }
        else {
            throw "Error de autenticación Centreon: $($_.Exception.Message)"
        }
    }
}