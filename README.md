# Participación ciudadana e identidad étnica en el Perú
## Análisis con microdatos ENAHO 2025

**Autoras:** María Alejandra Ponce de León y Vania Prado  
**Curso:** Taller de Procesamiento de Datos — PUCP, 2026-1  
**Docente:** José Luis Incio Coronado  

---

## Pregunta de investigación

¿En qué medida la identidad étnica —aproximada mediante la lengua materna— se asocia con la participación ciudadana en organizaciones sociales y comunales en el Perú?

## Descripción

Este proyecto procesa y analiza los microdatos de la Encuesta Nacional de Hogares (ENAHO) 2025 del INEI para explorar la relación entre identidad étnica y participación ciudadana en el Perú. Se aplican las seis dimensiones del procesamiento cuantitativo de datos: EXTRAER, GESTIONAR, ACONDICIONAR, EXPLORAR, CLASIFICAR y DOCUMENTAR.

La unidad de análisis es la **persona mayor de 18 años** (n muestral = 76,222; población representada ≈ 25.2 millones).

## Hallazgo principal

Los hablantes de lenguas indígenas (quechua, aimara y otras lenguas nativas) participan en organizaciones sociales a una tasa **2.5 veces mayor** que los castellanohablantes:
- Población indígena: 53.9% participa en al menos una organización
- Población no indígena: 21.1% participa en al menos una organización

---

## Estructura del repositorio

```
PoncedeLeon_MariaAlejandra_Prado_Vania/
│
├── 01_datos/
│   ├── originales/          ← Módulos ENAHO originales (no versionados)
│   └── procesados/          ← Bases generadas por los scripts
│       ├── base_unida.csv         (script 01)
│       ├── base_acondicionada.csv (script 02)
│       └── base_final.csv         (script 04)
│
├── 02_scripts/              ← Un script por dimensión
│   ├── 01_extraer.R
│   ├── 02_acondicionar.R
│   ├── 03_explorar.R
│   ├── 04_clasificar.R
│   └── 05_documentar.R
│
├── 03_outputs/              ← Outputs por dimensión
│   ├── acondicionar/
│   ├── explorar/
│   ├── clasificar/
│   └── documentar/
│
├── 04_docs/
│   └── ficha_tecnica_ENAHO.md   ← Diseño muestral y limitaciones
│
├── renv.lock                ← Versiones de paquetes (reproducibilidad)
└── README.md                ← Este archivo

```
---

## Reproducibilidad

Este proyecto usa `renv` para gestionar versiones de paquetes. Para reproducir:

```r
# 1. Restaurar el entorno de paquetes
renv::restore()

# 2. Colocar los módulos ENAHO en 01_datos/originales/:
#    - Sumaria-2025-12g.sav
#    - Enaho01A-2025-300_Educacion.sav
#    - Enaho01-2025-800A.sav
#    - Enaho01-2025-800B.sav
#    Descarga: https://iinei.inei.gob.pe/microdatos/

# 3. Ejecutar los scripts en orden
source("02_scripts/01_extraer.R")
source("02_scripts/02_acondicionar.R")
source("02_scripts/03_explorar.R")
source("02_scripts/04_clasificar.R")
source("02_scripts/05_documentar.R")
```

**Paquetes utilizados:** `tidyverse`, `haven`, `skimr`, `quantreg`

---

## 1. EXTRAER

**Script:** `02_scripts/01_extraer.R`  
**Documentación técnica:** `04_docs/ficha_tecnica_ENAHO.md`

Se utilizaron 4 módulos de la ENAHO 2025, descargados del portal oficial del INEI:

| Módulo | Archivo | Variables utilizadas |
|--------|---------|---------------------|
| Sumaria | `Sumaria-2025-12g.sav` | POBREZA, ESTRATO, FACTOR07 |
| 300 — Educación | `Enaho01A-2025-300_Educacion.sav` | P300A (lengua materna), P301A, P207, P208A |
| 800A — Gobernabilidad | `Enaho01-2025-800A.sav` | P801_1 a P801_17 (participación en organizaciones) |
| 800B — Gobernabilidad | `Enaho01-2025-800B.sav` | P803, P804, P805 (detalle individual) |

**Decisiones metodológicas:**
- Se usa **lengua materna (P300A)** como proxy de identidad étnica en lugar de la pregunta de autoidentificación directa. Justificación: la autoidentificación directa está sujeta a sesgo por racismo estructural — en contextos de discriminación, las personas tienden a declararse "mestizas" ocultando su identidad indígena (MNAR). La lengua materna es un hecho biográfico menos susceptible a ese sesgo.
- El módulo 800B tiene múltiples registros por persona (hasta 5). Se conservó el registro con el **rol más activo** (menor valor en P804: 1=Dirigente > 2=Miembro activo > 3=Miembro no activo > 4=Otro).
- La unión se hizo con **left_join** para conservar a todas las personas del módulo 300, incluso quienes no participan en ninguna organización (no tienen registro en 800B).
- Resultado: **104,446 personas**, sin duplicaciones en el merge.

---

## 2. GESTIONAR

**Script:** `02_scripts/00_estructura.R` (ejecutado al inicio)

- Estructura de carpetas organizada en 4 directorios principales
- Control de versiones con Git y GitHub desde el inicio del proyecto
- Gestión de paquetes con `renv` para garantizar reproducibilidad
- Datos originales excluidos del versionamiento (`.gitignore`) por peso y restricciones de redistribución del INEI
- Commits descriptivos por cada decisión metodológica (ver historial en GitHub)

---

## 3. ACONDICIONAR

**Script:** `02_scripts/02_acondicionar.R`

A partir de la base unida (104,446 personas de todas las edades), se aplicaron los siguientes pasos:

**Selección de variables:** se seleccionaron 6 variables analíticas con justificación teórica explícita para cada control:

| Variable | Rol | Justificación |
|----------|-----|---------------|
| `etnia` | Independiente principal | Proxy de identidad étnica (lengua materna) |
| `part_indice` | Dependiente | Índice de participación en organizaciones (0–17) |
| `educacion` | Control | La educación aumenta la participación cívica independientemente de la etnia |
| `sexo` | Control | Diferencias de género en participación documentadas en el Perú |
| `area` | Control | Participación comunal estructuralmente distinta en contextos rurales vs. urbanos |
| `pobreza` | Control | Puede confundir la relación entre etnia y participación |
| `factor_exp` | Ponderación | Obligatorio para análisis representativo a nivel nacional |

**Corrección de tipos:** variables categóricas convertidas de numérico a factor con etiquetas del diccionario ENAHO.

**Gestión de NAs:** solo `educacion` presentó valores perdidos (225 casos, 0.22%). Se aplicó listwise deletion porque:
- El porcentaje es estadísticamente insignificante (< 1%)
- No hay evidencia de patrón sistemático (plausiblemente MCAR)
- La imputación múltiple no se justifica con menos del 1% de ausencias (van Buuren, 2018)

**Filtro de edad:** se restringió el análisis a **personas de 18 años o más** porque la participación ciudadana en organizaciones formales es un derecho que se ejerce a partir de la mayoría de edad en el Perú.

**Resultado:** base acondicionada con **76,222 observaciones** (73% del total).

