# utf-8
# tptCentreon

Módulo PowerShell que envuelve la API REST oficial de Centreon (20+) para monitorización de infraestructura.

## Función

Proporciona 6 funciones de inventario TPT (prefijo `tpt` en módulos y funciones) para gestionar la conexión y recuperar datos de hosts, servicios, métricas, alertas y estado.

## Tabla de funciones

| Función | Parámetros | Descripción |
|---------|-----------|-------------|
| `Connect-tptCentreon` | `-Url`, `-Credential` | Autentica contra Centreon y guarda el token |
| `Get-tptCentreonHosts` | `-Name` | Obtiene hosts de inventario con filtros opcionales |
| `Get-tptCentreonServices` | `-Name`, `-HostName` | Obtiene servicios con filtros opcionales |
| `Get-tptCentreonMetrics` | `-HostName`, `-MetricName` | Obtiene métricas para hosts específicos |
| `Get-tptCentreonAlerts` | `-Severity`, `-Limit` | Obtiene alertas filtradas por severidad |
| `Get-tptCentreonStatus` | - | Devuelve el estado de conexión y versión |

## Requisitos

- PowerShell 7.2+
- Centreon 20+ con API REST habilitada (puerto 8080 por defecto)

## Ejemplo de uso

```powershell
# Autenticar contra Centreon
$cred = Get-Credential
Connect-tptCentreon -Url 'https://centreon.example.com:8080' -Credential $cred

# Listar todos los hosts
Get-tptCentreonHosts

# Listar servicios para un host específico
Get-tptCentreonServices -HostName 'web-server-01'

# Obtener métricas de CPU para un host
Get-tptCentreonMetrics -HostName 'web-server-01' -MetricName '*cpu*'

# Obtener alertas críticas recientes
Get-tptCentreonAlerts -Severity 'CRITICAL' -Limit 10

# Verificar estado de conexión
Get-tptCentreonStatus
```

## Configuración

Las credenciales deben ser proporcionadas al llamar a `Connect-tptCentreon`. El módulo guarda el token de autenticación y URL base en el estado del módulo ($script:CentreonToken, $script:CentreonUrl) para reutilizar en llamadas posteriores.

## Licencia

GPL-3.0
