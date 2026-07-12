# =============================================================================
# Script 01: EXTRAER — Carga y unión de módulos ENAHO 2025
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   1. Se usan 4 módulos de la ENAHO 2025: Sumaria, 300, 800A y 800B
#   2. La unión entre módulos se hace por las llaves oficiales del INEI:
#      CONGLOME + VIVIENDA + HOGAR (nivel hogar) y + CODPERSO (nivel persona)
#   3. Se usa left_join para conservar todos los casos del módulo 300
#      (personas), incluso si no tienen registro en 800B (solo tienen
#      registro quienes participan en alguna organización)
#   4. Se exporta la base unida sin modificaciones para preservar el dato
#      crudo. Toda limpieza ocurre en el script 02_acondicionar.R
# =============================================================================

library(tidyverse)
library(haven)

# =============================================================================
# 1. CARGA DE MÓDULOS
# Decisión: se seleccionan solo las variables relevantes para el análisis
# desde el momento de la carga para reducir el peso de la base.
# La selección está justificada en la ficha técnica (04_docs/ficha_tecnica_ENAHO.md)
# =============================================================================

# --- Sumaria: variables socioeconómicas del hogar ----------------------------
# Unidad de análisis: HOGAR
# Variables seleccionadas: identificadores + pobreza + estrato + factor de expansión
sumaria <- read_sav("01_datos/originales/Sumaria-2025-12g.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR,
    DOMINIO,     # dominio geográfico
    ESTRATO,     # estrato geográfico (determina área urbano/rural)
    ESTRSOCIAL,  # estrato socioeconómico (A, B, C, D, E, Rural)
    MIEPERHO,    # número de miembros del hogar
    POBREZA,     # condición de pobreza (1=Pobre extremo, 2=Pobre no extremo, 3=No pobre)
    FACTOR07     # factor de expansión — obligatorio para análisis representativo a nivel nacional
  )

cat(sprintf("Sumaria cargada: %d hogares\n", nrow(sumaria)))

# --- Módulo 300: Educación ---------------------------------------------------
# Unidad de análisis: PERSONA
# Variables seleccionadas: identificadores + lengua materna + nivel educativo +
#                          sexo + edad
# Decisión: P300A (lengua materna) se usa como proxy de identidad étnica.
# Justificación completa en 04_docs/ficha_tecnica_ENAHO.md, sección 5.
mod300 <- read_sav("01_datos/originales/Enaho01A-2025-300_Educacion.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    P300A,   # lengua materna (proxy de identidad étnica)
    P301A,   # nivel educativo alcanzado
    P207,    # sexo (1=Hombre, 2=Mujer)
    P208A    # edad en años cumplidos
  )

cat(sprintf("Módulo 300 cargado: %d personas\n", nrow(mod300)))

# --- Módulo 800A: Gobernabilidad — participación del hogar -------------------
# Unidad de análisis: HOGAR
# Cada P801_* indica si alguien del hogar pertenece a ese tipo de organización
# Decisión: se incluyen P801_1 a P801_17 (tipos de organización) y P801_19
#           (no pertenece a ninguna, categoría de referencia)
mod800A <- read_sav("01_datos/originales/Enaho01-2025-800A.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR,
    P801_1,   # Clubes y asociaciones deportivas
    P801_2,   # Agrupación o partido político
    P801_3,   # Clubes culturales
    P801_4,   # Asociación vecinal / Junta vecinal
    P801_5,   # Ronda campesina
    P801_6,   # Asociación de regantes
    P801_7,   # Asociación profesional
    P801_8,   # Asociación de trabajadores o sindicato
    P801_9,   # Club de madres
    P801_10,  # Asociación de padres de familia (APAFA)
    P801_11,  # Vaso de leche
    P801_12,  # Comedor popular
    P801_13,  # Comité local administrativo de salud (CLAS)
    P801_14,  # Proceso de presupuesto participativo
    P801_15,  # Concejo de coordinación local distrital
    P801_16,  # Comunidad campesina
    P801_17,  # Asociación agropecuaria
    P801_19   # No pertenece a ninguna organización
  )

cat(sprintf("Módulo 800A cargado: %d hogares\n", nrow(mod800A)))

# --- Módulo 800B: Gobernabilidad — detalle individual -----------------------
# Unidad de análisis: PERSONA que participa en alguna organización
# Decisión: solo tienen registro en este módulo las personas que SÍ participan.
#           Por eso se usa left_join al unir con el módulo 300, para conservar
#           también a quienes no participan (quedarán con NA en estas variables).
mod800B <- read_sav("01_datos/originales/Enaho01-2025-800B.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    P803,    # tipo de organización a la que pertenece
    P804,    # rol: Dirigente / Miembro activo / Miembro no activo / Otro
    P805     # cómo accedió: elección, amistad, designación, pago, afiliación, otro
  )

cat(sprintf("Módulo 800B cargado: %d registros de participación individual\n", nrow(mod800B)))

