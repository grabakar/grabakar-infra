# GrabaKar — Infraestructura y Orquestación

Meta-repositorio que orquesta todos los componentes del proyecto GrabaKar.

## Repositorios del Proyecto

| Repo | Descripción | Stack |
|---|---|---|
| [grabakar-backend](https://github.com/grabakar/grabakar-backend) | API REST, lógica de negocio, sync | Django 5+, DRF, PostgreSQL, Celery, Redis |
| [grabakar-frontend](https://github.com/grabakar/grabakar-frontend) | PWA React, exportable a Ionic | React 18+, TypeScript, Vite, Capacitor |
| [grabakar-docs](https://github.com/grabakar/grabakar-docs) | Documentación completa | Markdown |

## Setup Rápido

### macOS / Linux

```bash
git clone https://github.com/grabakar/grabakar-infra.git
cd grabakar-infra
chmod +x scripts/setup.sh
./scripts/setup.sh
cp .env.example .env
docker compose up -d
```

### Windows (PowerShell o CMD)

```powershell
git clone https://github.com/grabakar/grabakar-infra.git
cd grabakar-infra
scripts\setup.bat
copy .env.example .env
docker compose up -d
```

## Servicios

| Servicio | Puerto | Descripción |
|---|---|---|
| Backend (Django) | `localhost:8000` | API REST |
| Frontend (React/Vite) | `localhost:5173` | Webapp con hot reload |
| PostgreSQL | `localhost:5432` | Base de datos |
| Redis | `localhost:6379` | Broker Celery + cache |
| Celery Worker | — | Procesamiento async |
| Celery Beat | — | Scheduler de tareas periódicas |

## Actualizar Repos

```bash
# macOS / Linux
./scripts/update.sh

# Windows
scripts\update.bat
```

## Estructura

```
grabakar-infra/
├── docker-compose.yml          # Orquestador del stack completo
├── .env.example                # Variables de entorno
├── scripts/
│   ├── setup.sh / setup.bat    # Clona todos los repos (macOS+Linux / Windows)
│   ├── update.sh / update.bat  # Pull latest de todos los repos
│   └── review_precheck.sh      # Pre-check de revisión de código
└── repos/                      # ← Los repos se clonan aquí
    ├── grabakar-backend/
    ├── grabakar-frontend/
    └── grabakar-docs/
```

## Desarrollo

- **Backend**: Código en `repos/grabakar-backend/`. Los cambios se reflejan automáticamente (volume mount + gunicorn --reload).
- **Frontend**: Código en `repos/grabakar-frontend/`. Hot reload vía Vite dev server.
- **Docs**: Código en `repos/grabakar-docs/`. Referencia para specs, contratos API y prompts de agentes.

Cada repo mantiene su propio CI/CD (GitHub Actions). Este repo solo orquesta el entorno de desarrollo local.
