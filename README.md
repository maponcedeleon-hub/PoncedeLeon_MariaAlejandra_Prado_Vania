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