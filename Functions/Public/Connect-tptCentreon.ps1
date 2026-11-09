# utf-8
function Connect-tptCentreon {
    <#
    .SYNOPSIS
        Autentica contra el API REST de Centreon y guarda el token para llamadas posteriores.

    .DESCRIPTION
        Establece una conexión autenticada con el servidor Centreon. Llama a
        Test-tptCentreonConnection para obtener el authToken y lo guarda en el
        estado del módulo ($script:CentreonToken). Si la autenticación tiene éxito,
        devuelve un objeto PSCustomObject con detalles de la conexión. Acepta -Platform
        para resolver la conexión desde la configuración centralizada.

    .PARAMETER Url
        URL base del servidor Centreon (incluir scheme y puerto).
        Si no se proporciona, usa $script:CentreonUrl si existe, o 'https://centreon.local'.
        Si se usa -Platform y Url no se proporciona, se toma del YAML.

    .PARAMETER Credential
        Credenciales de Centreon (usuario y contraseña). Se requieren para la autenticación.

    .PARAMETER Platform
        Nombre de la plataforma desde la configuración centralizada (YAML).
        Si se proporciona, el valor de Url se toma del YAML a menos que se proporcione
        explícitamente.

    .EXAMPLE
        Connect-tptCentreon -Url 'https://centreon.example.com:8080' -Credential (Get-Credential)
        Autentica con el servidor Centreon y guarda el token usando URL explícito.

    .EXAMPLE
        Connect-tptCentreon -Credential (Get-Credential) -Platform centreon-prod
        Resuelve la plataforma centreon-prod desde el YAML centralizado.

    .EXAMPLE
        Connect-tptCentreon -Platform centreon-prod -Credential (Get-Credential)
        Resuelve desde YAML, usa Url del YAML (no es necesario -Url explícito).

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Url, User, Connected (true), ApiVersion.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [Parameter(Mandatory = $false)]
        [string]$Platform = $null,

        [string]$Url = $null,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCredential]$Credential
    )

    Import-Module (Join-Path $PSScriptRoot -ChildPath 'TPT-Helpers.ps1') -Force

    # Resolver URL desde YAML si -Platform está presente
    if ($Platform) {
        $config = Get-tptCentreonConfig
        $selectedPlatform = $config | Where-Object { $_.name -eq $Platform }
        
        if (-not $selectedPlatform) {
            throw "Plataforma '$Platform' no encontrada en la configuración de tptCentreon."
        }

        # Usar Url del YAML solo si no se proporcionó explícitamente
        if (-not $Url) { $Url = $selectedPlatform.url }
    }

    # Usar URL por defecto si no se proporciona
    if (-not $Url) {
        $Url = $script:CentreonUrl ?? "https://centreon.local"
    }

    # Autenticar contra Centreon
    $token = Test-tptCentreonConnection -Url $Url -Credential $Credential

    # Guardar token y URL en estado del módulo
    $script:CentreonToken = $token
    $script:CentreonUrl = $Url

    # Construir objeto de conexión
    [PSCustomObject]@{
        Url = $Url
        User = $Credential.UserName
        Connected = $true
        ApiVersion = '1.0'
    }
}