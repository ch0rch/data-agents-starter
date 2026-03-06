# data-agents-starter

Workspace de IA multiagente para proyectos de Data Engineering con dbt Core y Airflow.

Diseñado para usar con **OpenCode** (o Cursor). Clonalo, adaptá los archivos de `knowledge/` a tu proyecto, y ya tenés un sistema de agentes especializado para tu stack de datos.

## Estructura

```
data-agents-starter/
├── .opencode/
│   ├── agents/              # Subagentes especializados
│   │   ├── AGENTS.md        # Agente orquestador (punto de entrada)
│   │   ├── dbt-agent.md     # Especialista en transformaciones dbt
│   │   ├── airflow-agent.md # Especialista en orquestación de pipelines
│   │   ├── analytics-agent.md # Consultas y métricas
│   │   └── docs-agent.md    # Documentación automática
│   └── skills/
│       └── dbt-core-contexto.md  # Contexto persistente del stack
├── knowledge/               # Base de conocimiento del proyecto
│   ├── overview.md          # Descripción general del proyecto de datos
│   ├── convenciones.md      # Reglas de nomenclatura y estilo SQL
│   └── fuentes.md           # Catálogo de tablas fuente
├── dbt-project/             # Proyecto dbt de ejemplo
│   ├── dbt_project.yml
│   ├── models/
│   │   ├── staging/
│   │   ├── intermediate/
│   │   └── marts/
│   ├── tests/
│   └── macros/
└── _inbox/                  # Los agentes escriben sus outputs acá
```

## Cómo empezar

1. Cloná el repo
2. Editá `knowledge/overview.md` con la descripción de tu proyecto
3. Editá `knowledge/fuentes.md` con tus tablas fuente reales
4. Abrí el proyecto en OpenCode/Cursor
5. Invocá al orquestador con `@AGENTS` y describí lo que necesitás

## Concepto clave: Feedback Loop y tokens

Cada subagente tiene un **contexto acotado** — solo lee lo que necesita para su tarea. Esto resuelve el problema de explotar la ventana de tokens cuando todo vive en un solo chat largo.

El flujo es:
```
Vos → @AGENTS (orquestador) → @dbt-agent / @airflow-agent / etc.
```

Cada subagente trabaja en su dominio y escribe el output en `_inbox/`. El orquestador coordina sin cargar todo el contexto a la vez.
