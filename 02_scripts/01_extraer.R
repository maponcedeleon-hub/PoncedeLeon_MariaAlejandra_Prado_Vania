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
sumaria <- read_sav("C:/Users/USUARIO/OneDrive/Escritorio/PC3_ENAHO/datos/crudos/Sumaria-2025-12g.sav") %>%
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
mod300 <- read_sav("C:/Users/USUARIO/OneDrive/Escritorio/PC3_ENAHO/datos/crudos/Enaho01A-2025-300_Educación.sav") %>%
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

mod800A <- read_sav("C:/Users/USUARIO/OneDrive/Escritorio/PC3_ENAHO/datos/crudos/Enaho01-2025-800A.sav") %>%
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
  
mod800B <- read_sav("C:/Users/USUARIO/OneDrive/Escritorio/PC3_ENAHO/datos/crudos/Enaho01-2025-800B.sav") %>%
  select(
    CONGLOME, VIVIENDA, HOGAR, CODPERSO,
    P803,    # tipo de organización a la que pertenece
    P804,    # rol: 1=Dirigente, 2=Miembro activo, 3=Miembro no activo, 4=Otro
    P805     # cómo accedió: elección, amistad, designación, pago, afiliación, otro
  ) %>%
  # Decisión: algunas personas tienen múltiples registros en 800B porque
  # participan en más de una organización (hasta 5 registros por persona).
  # Se conserva el registro con el rol más activo (valor más bajo en P804:
  # 1=Dirigente > 2=Miembro activo > 3=Miembro no activo > 4=Otro).
  # Justificación: el perfil de participación más relevante para el análisis
  # de ciudadanía activa es el rol de mayor involucramiento.
  group_by(CONGLOME, VIVIENDA, HOGAR, CODPERSO) %>%
  slice_min(P804, with_ties = FALSE) %>%
  ungroup()

cat(sprintf("Módulo 800B cargado: %d registros (uno por persona, rol más activo)\n",
            nrow(mod800B)))

# =============================================================================
# 2. CONSTRUCCIÓN DEL ÍNDICE DE PARTICIPACIÓN (nivel hogar)
# Decisión: se construye el índice antes del merge para que quede documentado
#           como parte de la extracción, no de la clasificación.
# Lógica: cada P801_* vale 1 si el hogar participa en ese tipo de organización,
#         0 si no. El índice es la suma de tipos distintos (0 a 17).
# Justificación: la suma simple es la forma más transparente y auditable de
#         construir un índice de participación cuando todas las dimensiones
#         tienen igual peso teórico a priori (ver S14 — decisiones de agregación)
# =============================================================================

vars_participacion <- paste0("P801_", 1:17)

mod800A <- mod800A %>%
  mutate(
    across(
      all_of(vars_participacion),
      ~ if_else(. != 0, 1L, 0L)
    ),
    indice_participacion = rowSums(across(all_of(vars_participacion)),
                                   na.rm = TRUE),
    participa_binario    = if_else(indice_participacion > 0, 1L, 0L)
  )

cat("Índice de participación construido.\n")
cat(sprintf("Hogares que participan en al menos una organización: %d (%.1f%%)\n",
            sum(mod800A$participa_binario),
            mean(mod800A$participa_binario) * 100))

# =============================================================================
# 3. MERGE DE MÓDULOS
# Decisión: se une en dos pasos para mantener claridad sobre las unidades
#           de análisis en cada join.
# Paso 1: unión a nivel persona (300 + 800B) → left_join porque 800B solo
#         tiene registros de quienes participan
# Paso 2: agregar índice del hogar (800A) → left_join por llaves de hogar
# Paso 3: agregar variables socioeconómicas (Sumaria) → left_join por hogar
# Llave de unión: CONGLOME + VIVIENDA + HOGAR + CODPERSO (persona)
#                 CONGLOME + VIVIENDA + HOGAR (hogar)
# Fuente: Diccionario de variables ENAHO 2025, INEI
# =============================================================================

# Paso 1: módulo 300 + 800B (nivel persona)
base_persona <- mod300 %>%
  left_join(mod800B,
            by = c("CONGLOME", "VIVIENDA", "HOGAR", "CODPERSO"))

filas_esperadas <- nrow(mod300)
filas_obtenidas <- nrow(base_persona)

cat(sprintf("\nPaso 1 — merge 300 + 800B:\n"))
cat(sprintf("  Filas esperadas: %d (igual que módulo 300)\n", filas_esperadas))
cat(sprintf("  Filas obtenidas: %d\n", filas_obtenidas))
if (filas_esperadas != filas_obtenidas) {
  warning("¡El merge produjo un número inesperado de filas! Revisar duplicados.")
} else {
  cat("  ✓ Merge correcto: no hubo duplicación de filas\n")
}

# Paso 2: agregar índice de participación del hogar (800A)
base_persona <- base_persona %>%
  left_join(
    mod800A %>% select(CONGLOME, VIVIENDA, HOGAR,
                       indice_participacion, participa_binario,
                       all_of(vars_participacion)),
    by = c("CONGLOME", "VIVIENDA", "HOGAR")
  )

cat(sprintf("\nPaso 2 — agregar 800A:\n"))
cat(sprintf("  Filas después del merge: %d\n", nrow(base_persona)))

# Paso 3: agregar Sumaria
base_unida <- base_persona %>%
  left_join(sumaria,
            by = c("CONGLOME", "VIVIENDA", "HOGAR"))

cat(sprintf("\nPaso 3 — agregar Sumaria:\n"))
cat(sprintf("  Filas finales: %d\n", nrow(base_unida)))
cat(sprintf("  Variables: %d\n", ncol(base_unida)))

# =============================================================================
# 4. EXPORTAR BASE UNIDA (sin modificaciones — dato crudo unido)
# =============================================================================

write_csv(base_unida, "01_datos/procesados/base_unida.csv")

cat("\n✓ Base unida exportada en 01_datos/procesados/base_unida.csv\n")
cat("  Próximo paso: acondicionar en 02_scripts/02_acondicionar.R\n")
