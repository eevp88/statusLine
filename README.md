# Claude Statusline

Statusline personalizado para [Claude Code](https://claude.ai/code) que muestra información útil del contexto actual en cada turno de conversación.

![statusline preview](https://raw.githubusercontent.com/eevp88/statusLine/main/preview.svg)

## Qué muestra

| Campo | Descripción |
|-------|-------------|
| `[ Modelo ]` | Nombre del modelo activo (ej: Claude Sonnet 4.6) |
| `👤 usuario` | Usuario del sistema |
| `📁 carpeta` | Nombre del directorio de trabajo actual |
| `🌿 branch` | Branch git activo (con fallback a submódulos HMVC) |
| `🧠 ██████░░░░ 60%` | Barra de uso del contexto (verde / amarillo / rojo) |
| `↑ / ↓` | Tokens de entrada y salida acumulados |
| `$0.00` | Costo acumulado de la sesión en USD |
| `🚧 rate limit` | Uso del rate limit con countdown al reset (si aplica) |

Todos los elementos son opcionales — el instalador te permite elegir cuáles mostrar.

### Alertas de contexto

- **75%+** → aviso suave: `💾 contexto casi lleno`
- **90%+** → alerta urgente parpadeante: `💾 GUARDÁ EL CONTEXTO`

## Requisitos

- `jq` — procesamiento de JSON
- `git` — detección de branch

El instalador los detecta e instala automáticamente si no están presentes.

## Instalación

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/eevp88/statusLine/main/install.sh)
```

Durante la instalación aparece un menú interactivo para elegir qué elementos mostrar:

```
  Configurá los elementos del statusline
  ↑↓ navegar  │  ESPACIO activar/desactivar  │  ENTER confirmar

  [x]  modelo       —  Modelo activo de Claude
  [x]  usuario      —  Usuario del sistema
  [x]  carpeta      —  Directorio de trabajo actual
  [x]  branch       —  Branch git activo
  [x]  contexto     —  Barra de uso del contexto
  [x]  tokens       —  Tokens de entrada y salida
  [x]  costo        —  Costo acumulado de la sesión
  [ ]  rate_limit   —  Rate limit con countdown al reset
  [x]  alertas      —  Alertas de contexto lleno
```

Reiniciá Claude Code al terminar.

## Reconfigurar elementos

Para cambiar qué elementos se muestran sin reinstalar:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/eevp88/statusLine/main/install.sh) --reconfigure
```

La configuración se guarda en `~/.claude/statusline.conf` y se aplica en el próximo turno.

## Actualizar

Corriendo el instalador de nuevo se detecta la versión instalada y se actualiza automáticamente, manteniendo tu configuración:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/eevp88/statusLine/main/install.sh)
```

## Instalación manual

1. Clonar el repo:
```bash
git clone https://github.com/eevp88/statusLine.git
cd statusLine
```

2. Ejecutar el instalador:
```bash
bash install.sh
```

## Archivo de configuración

La configuración se guarda en `~/.claude/statusline.conf`:

```bash
SHOW_MODEL=1
SHOW_USER=1
SHOW_DIR=1
SHOW_BRANCH=1
SHOW_CONTEXT=1
SHOW_TOKENS=1
SHOW_COST=1
SHOW_RATE=0
SHOW_ALERTS=1
```

Podés editarlo manualmente — los cambios se aplican en el próximo turno sin reiniciar nada.

## Desinstalación

Eliminá el bloque `statusLine` de `~/.claude/settings.json` y borrá `~/.claude/scripts/status.sh`.

## Licencia

MIT
