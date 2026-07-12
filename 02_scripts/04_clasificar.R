# =============================================================================
# Script 04: CLASIFICAR — Creación de variables analíticas
# Proyecto: Participación ciudadana e identidad étnica en el Perú
# Autoras: María Alejandra Ponce de León y Vania Prado
# Curso: Taller de Procesamiento de Datos — PUCP
# Fecha: julio 2026
# -----------------------------------------------------------------------------
# Decisiones de esta etapa:
#   Se crean tres variables analíticas nuevas a partir de las exploradas en
#   el script 03.
#
#   Variable 1: indigena (dummy binaria)
#   Concepto: pertenencia a un grupo étnico indígena
#   Operacionalización: lengua materna indígena vs. castellano
#   Justificación del corte: la distinción indígena/no indígena es la
#     categoría analítica central en la literatura sobre ciudadanía étnica
#     en América Latina (Yashar, 2005; Van Cott, 2005; Sulmont, 2012).
#     El corte es teórico, no basado en datos, lo que permite comparabilidad
#     con otros estudios del campo.
#   Limitación: las lenguas amazónicas tienen muy baja frecuencia muestral
#     (n < 500 cada una), por lo que se agrupan con quechua y aimara bajo
#     la categoría "indígena". Esto implica asumir que comparten un patrón
#     de participación similar, supuesto que la exploración bivariada apoya
#     pero no confirma definitivamente.
#
#   Variable 2: nivel_participacion (ordinal, 3 categorías)
#   Concepto: intensidad de la participación ciudadana en organizaciones
#   Operacionalización: recodificación del índice part_indice en tres niveles
#   Justificación del corte:
#     - "Ninguna" (0): no participa en ninguna organización — categoría
#       sustantivamente distinta porque implica ausencia total de vínculos
#       organizacionales formales
#     - "Baja" (1–2): participación en una o dos organizaciones — nivel
#       típico de participación instrumental (ej. APAFA, vaso de leche)
#     - "Alta" (3 o más): participación en tres o más organizaciones — indica
#       un perfil de ciudadanía activa y múltiple vinculación comunitaria
#     Los cortes se basan en la distribución observada en EXPLORAR:
#     el 72.3% no participa, el 22.2% participa en una organización, y
#     solo el 5.4% en tres o más. El corte en 3 separa un grupo cuali-
#     tativamente distinto de alta participación.
#
#   Variable 3: participa_comunal (dummy)
#   Concepto: participación en organizaciones de base territorial/comunal
#   Operacionalización: 1 si el hogar participa en junta vecinal (P801_4),
#     ronda campesina (P801_5), comunidad campesina (P801_16) o presupuesto
#     participativo (P801_14)
#   Justificación: estas organizaciones son las más directamente vinculadas
#     a la ciudadanía local y a las formas tradicionales de organización
#     indígena en el Perú. Su análisis separado permite distinguir entre
#     participación genérica y participación político-territorial.
# =============================================================================

library(tidyverse)

# -----------------------------------------------------------------------------
# Cargar base acondicionada
# -----------------------------------------------------------------------------

base <- read_csv("01_datos/procesados/base_acondicionada.csv",
                 show_col_types = FALSE) %>%
  mutate(
    etnia     = factor(etnia,
                       levels = c("Castellano", "Quechua", "Aimara",
                                  "Otra lengua nativa", "Ashaninka",
                                  "Awajun/Aguaruna", "Shipibo-Konibo",
                                  "Shawi/Chayahuita", "Matsigenka/Machiguenga",
                                  "Achuar", "Otra")),
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

cat(sprintf("Base cargada: %d observaciones\n", nrow(base)))

# =============================================================================
# 1. VARIABLE: indigena (dummy binaria)
# =============================================================================

base <- base %>%
  mutate(
    indigena = case_when(
      etnia == "Castellano" ~ 0L,
      etnia == "Otra"       ~ NA_integer_,  # categoría ambigua, se excluye
      TRUE                  ~ 1L            # todas las lenguas nativas
    ),
    indigena_label = factor(indigena,
                            levels = c(0, 1),
                            labels = c("No indígena", "Indígena"))
  )

# Distribución ponderada
dist_indigena <- base %>%
  filter(!is.na(indigena)) %>%
  group_by(indigena_label) %>%
  summarise(
    n           = n(),
    n_expandido = round(sum(factor_exp))
  ) %>%
  mutate(pct = round(n_expandido / sum(n_expandido) * 100, 1))

cat("\n=== Variable 1: indigena ===\n")
cat("Regla: 1 = lengua materna indígena; 0 = castellano; NA = otra\n")
cat("Nota: 'Otra' (n=300) excluida por ambigüedad — no es lengua\n")
cat("      nativa ni castellano claramente\n\n")
print(dist_indigena)
write_csv(dist_indigena, "03_outputs/clasificar/tabla_dist_indigena.csv")

# Gráfico
g_indigena <- ggplot(dist_indigena,
                     aes(x = indigena_label, y = pct,
                         fill = indigena_label)) +
  geom_col(show.legend = FALSE) +
  geom_text(aes(label = paste0(pct, "%\n(n expandido = ",
                               format(n_expandido, big.mark = ","), ")")),
            vjust = -0.3, size = 3.5) +
  scale_fill_manual(values = c("No indígena" = "#2980b9",
                               "Indígena"    = "#e67e22")) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.2))) +
  labs(
    title    = "Figura 8. Distribución de la variable 'indigena'",
    subtitle = "Recodificación binaria a partir de lengua materna — ENAHO 2025\n(n muestral = 75,922, excluyendo categoría 'Otra')",
    x        = NULL,
    y        = "Porcentaje de la población adulta (%)",
    caption  = "Fuente: ENAHO 2025 - INEI. Elaboración propia.\nNota: resultados ponderados con factor de expansión FACTOR07."
  ) +
  theme_minimal()

ggsave("03_outputs/clasificar/figura8_dist_indigena.png",
       plot = g_indigena, width = 6, height = 5, dpi = 300)

cat("✓ Variable 'indigena' creada y exportada.\n")
