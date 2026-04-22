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

### Alertas de contexto

- **75%+** → aviso suave: `💾 contexto casi lleno`
- **90%+** → alerta urgente parpadeante: `💾 GUARDÁ EL CONTEXTO`

## Requisitos

- `jq` — procesamiento de JSON
- `git` — detección de branch

El instalador los detecta e instala automáticamente si no están presentes.

## Instalación automática

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/eevp88/statusLine/main/install.sh)
```

## Instalación manual

1. Clonar el repo:
```bash
git clone https://github.com/eevp88/statusLine.git
cd statusLine
```

2. Copiar el script:
```bash
mkdir -p ~/.claude/scripts
cp status.sh ~/.claude/scripts/status.sh
chmod +x ~/.claude/scripts/status.sh
```

3. Agregar en `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "/home/TU_USUARIO/.claude/scripts/status.sh"
  }
}
```

4. Reiniciar Claude Code.

## Desinstalación

Eliminá el bloque `statusLine` de `~/.claude/settings.json` y borrá `~/.claude/scripts/status.sh`.

## Licencia

MIT
