# =============================================================================
# Script 05: DOCUMENTAR — Codebook y ficha técnica del dataset final
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   1. Se construye un codebook completo con todos los componentes
#      obligatorios: nombre, etiqueta, tipo, valores posibles,
#      frecuencias/distribución y fuente original
#   2. Se genera un reporte de estadísticos descriptivos con skimr
#   3. Se documenta la cadena de decisiones metodológicas del proyecto
# =============================================================================

library(tidyverse)
library(skimr)

# -----------------------------------------------------------------------------
# Cargar base final
# -----------------------------------------------------------------------------

base <- read_csv("01_datos/procesados/base_final.csv",
                 show_col_types = FALSE) %>%
  mutate(
    etnia = factor(etnia,
                   levels = c("Castellano", "Quechua", "Aimara",
                              "Otra lengua nativa", "Ashaninka",
                              "Awajun/Aguaruna", "Shipibo-Konibo",
                              "Shawi/Chayahuita", "Matsigenka/Machiguenga",
                              "Achuar", "Otra")),
    indigena_label      = factor(indigena_label,
                                 levels = c("No indígena", "Indígena")),
    nivel_participacion = factor(nivel_participacion,
                                 levels = c("Ninguna", "Baja", "Alta")),
    educacion = factor(educacion,
                       levels = c("Sin nivel / Inicial", "Primaria",
                                  "Secundaria", "Superior no universitaria",
                                  "Superior universitaria o más")),
    sexo      = factor(sexo, levels = c("Hombre", "Mujer")),
    area      = factor(area, levels = c("Urbano", "Rural")),
    pobreza   = factor(pobreza,
                       levels = c("Pobre extremo", "Pobre no extremo",
                                  "No pobre")),
    edad_grupo = factor(edad_grupo,
                        levels = c("18-29", "30-44", "45-59", "60 o más"))
  )

cat(sprintf("Base final cargada: %d observaciones, %d variables\n",
            nrow(base), ncol(base)))

# =============================================================================
# 1. CODEBOOK COMPLETO
# Componentes obligatorios: nombre, etiqueta descriptiva, tipo,
# valores posibles, fuente original
# =============================================================================

codebook <- tibble(
  variable = c(
    "CONGLOME", "VIVIENDA", "HOGAR", "CODPERSO",
    "etnia", "indigena", "indigena_label",
    "part_indice", "part_bin",
    "nivel_participacion", "participa_comunal",
    "educacion", "sexo", "area", "pobreza", "edad_grupo",
    "factor_exp"
  ),
  etiqueta = c(
    "Código de conglomerado",
    "Código de vivienda",
    "Código de hogar",
    "Código de persona",
    "Lengua materna (proxy de identidad étnica)",
    "Identidad indígena binaria (dummy)",
    "Etiqueta legible de variable indigena",
    "Índice de participación en organizaciones (0–5 en esta muestra)",
    "Participa en al menos una organización (dummy)",
    "Nivel de participación ciudadana (ordinal)",
    "Participa en organización comunal/territorial (dummy)",
    "Nivel educativo alcanzado",
    "Sexo de la persona",
    "Área geográfica de residencia",
    "Condición de pobreza del hogar",
    "Grupo etario",
    "Factor de expansión poblacional"
  ),
  tipo = c(
    "ID (texto)", "ID (texto)", "ID (numérico)", "ID (texto)",
    "Categórica nominal", "Dummy binaria", "Categórica nominal",
    "Numérica discreta", "Dummy binaria",
    "Ordinal", "Dummy binaria",
    "Ordinal", "Dummy binaria", "Dummy binaria", "Ordinal",
    "Ordinal", "Numérica continua"
  ),
  rol = c(
    "Identificador", "Identificador", "Identificador", "Identificador",
    "Independiente principal", "Analítica (creada en script 04)",
    "Analítica (creada en script 04)",
    "Dependiente", "Dependiente (binaria)",
    "Analítica (creada en script 04)", "Analítica (creada en script 04)",
    "Control", "Control", "Control", "Control", "Control",
    "Ponderación"
  ),
  valores_posibles = c(
    "Texto (6 dígitos)", "Texto (3 dígitos)",
    "Numérico", "Texto (2 dígitos)",
    "Castellano / Quechua / Aimara / Otra lengua nativa / Ashaninka / Awajun-Aguaruna / Shipibo-Konibo / Shawi-Chayahuita / Matsigenka-Machiguenga / Achuar / Otra",
    "0 = No indígena; 1 = Indígena; NA = Otra lengua",
    "No indígena / Indígena",
    "0 a 5 (máximo teórico: 17)",
    "0 = No participa; 1 = Participa",
    "Ninguna / Baja / Alta",
    "0 = No participa; 1 = Participa en org. comunal",
    "Sin nivel / Primaria / Secundaria / Superior no universitaria / Superior universitaria o más",
    "Hombre / Mujer",
    "Urbano / Rural",
    "Pobre extremo / Pobre no extremo / No pobre",
    "18-29 / 30-44 / 45-59 / 60 o más",
    "Valor positivo — indica cuántas personas representa en la población"
  ),
  fuente = c(
    rep("ENAHO 2025 - INEI (llaves de identificación)", 4),
    "ENAHO 2025 - Módulo 300, variable P300A (lengua materna)",
    "Construida en 04_clasificar.R a partir de etnia",
    "Construida en 04_clasificar.R a partir de indigena",
    "Construida en 01_extraer.R a partir de P801_1 a P801_17 (Módulo 800A)",
    "Construida en 01_extraer.R a partir de indice_participacion",
    "Construida en 04_clasificar.R a partir de part_indice",
    "Construida en 04_clasificar.R a partir de P801_4, P801_5, P801_14, P801_16",
    "ENAHO 2025 - Módulo 300, variable P301A",
    "ENAHO 2025 - Módulo 300, variable P207",
    "ENAHO 2025 - Sumaria, variable ESTRATO",
    "ENAHO 2025 - Sumaria, variable POBREZA",
    "ENAHO 2025 - Módulo 300, variable P208A (recodificada)",
    "ENAHO 2025 - Sumaria, variable FACTOR07"
  )
)

cat("\n=== CODEBOOK ===\n")
print(codebook)
write_csv(codebook, "03_outputs/documentar/codebook.csv")
cat("✓ Codebook exportado.\n")

# =============================================================================
# 2. FRECUENCIAS POR VARIABLE
# Codebook: distribución de cada variable
# =============================================================================

cat("\n=== FRECUENCIAS POR VARIABLE ===\n")

# Variables categóricas y ordinales
vars_categoricas <- c("etnia", "indigena_label", "nivel_participacion",
                      "educacion", "sexo", "area", "pobreza", "edad_grupo")

frecuencias <- map(vars_categoricas, function(var) {
  base %>%
    group_by(valor = .data[[var]]) %>%
    summarise(
      n           = n(),
      n_expandido = round(sum(factor_exp)),
      .groups     = "drop"
    ) %>%
    mutate(
      variable = var,
      pct      = round(n_expandido / sum(n_expandido) * 100, 1)
    ) %>%
    select(variable, valor, n, n_expandido, pct)
}) %>%
  bind_rows()

print(frecuencias)
write_csv(frecuencias,
          "03_outputs/documentar/tabla_frecuencias_variables.csv")

# Variables numéricas: estadísticos descriptivos ponderados
cat("\n=== ESTADÍSTICOS DESCRIPTIVOS PONDERADOS ===\n")

estadisticos_num <- tibble(
  variable = c("part_indice", "part_bin", "participa_comunal",
               "indigena", "factor_exp"),
  media_ponderada = c(
    weighted.mean(base$part_indice,       w = base$factor_exp),
    weighted.mean(base$part_bin,          w = base$factor_exp),
    weighted.mean(base$participa_comunal, w = base$factor_exp),
    weighted.mean(base$indigena,          w = base$factor_exp,
                  na.rm = TRUE),
    mean(base$factor_exp)
  ),
  mediana = c(
    median(base$part_indice),
    median(base$part_bin),
    median(base$participa_comunal),
    median(base$indigena, na.rm = TRUE),
    median(base$factor_exp)
  ),
  minimo = c(
    min(base$part_indice),
    min(base$part_bin),
    min(base$participa_comunal),
    min(base$indigena, na.rm = TRUE),
    min(base$factor_exp)
  ),
  maximo = c(
    max(base$part_indice),
    max(base$part_bin),
    max(base$participa_comunal),
    max(base$indigena, na.rm = TRUE),
    max(base$factor_exp)
  )
) %>%
  mutate(across(where(is.numeric), ~ round(., 3)))

print(estadisticos_num)
write_csv(estadisticos_num,
          "03_outputs/documentar/tabla_estadisticos_numericos.csv")

# =============================================================================
# 3. REPORTE SKIMR
# =============================================================================

cat("\n=== REPORTE SKIMR ===\n")
reporte_skim <- skim(base)
print(reporte_skim)

reporte_skim %>%
  as_tibble() %>%
  write_csv("03_outputs/documentar/reporte_skim.csv")

cat("✓ Frecuencias y reporte estadístico exportados.\n")

