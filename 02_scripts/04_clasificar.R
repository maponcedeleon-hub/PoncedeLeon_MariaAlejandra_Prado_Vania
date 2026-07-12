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
