############################################################################
# MST Experiment – Report 1: Complete Analysis in R
# Descriptive Statistics, Visualisations, Normality Checks,
# Inferential Tests with Bonferroni/BH p-value Corrections
############################################################################

# ── 0. Libraries & Setup ──────────────────────────────────────────────────
suppressPackageStartupMessages({
  library(tidyverse)
  library(psych)
  library(effectsize)
  library(ggpubr)
  library(car)
})

BASE   <- "/home/anurag/Documents/BRSM/MST_Simpletons"
DATA   <- file.path(BASE, "extracted_data")
PLOTS  <- file.path(BASE, "report1_plots")
dir.create(PLOTS, showWarnings = FALSE)

REPORT <- file.path(BASE, "Report1_Results.txt")
sink_file <- file(REPORT, open = "wt")

report <- function(...) {
  msg <- paste0(...)
  cat(msg, "\n")                    # console
  cat(msg, "\n", file = sink_file)  # file
}

report("================================================================")
report("  MST EXPERIMENT – REPORT 1: COMPLETE ANALYSIS")
report("  Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
report("================================================================\n")

# ── 1. Load Extracted Data ── ─────────────────────────────────────────────
retrieval  <- read_csv(file.path(DATA, "retrieval_trials.csv"),   show_col_types = FALSE)
metrics    <- read_csv(file.path(DATA, "participant_metrics.csv"), show_col_types = FALSE)
lure_bins  <- read_csv(file.path(DATA, "lure_bin_metrics.csv"),   show_col_types = FALSE)
enc_rt     <- read_csv(file.path(DATA, "encoding_rt_summary.csv"), show_col_types = FALSE)

# Factor levels
metrics$boundary_position <- factor(metrics$boundary_position,
                                    levels = c("pre", "mid", "post"))
metrics$group <- factor(metrics$group,
                        levels = c("item_only", "task_only", "Both_item_task"))
retrieval$boundary_position <- factor(retrieval$boundary_position,
                                      levels = c("pre", "mid", "post", "none"))
retrieval$group <- factor(retrieval$group,
                          levels = c("item_only", "task_only", "Both_item_task"))
lure_bins$group <- factor(lure_bins$group,
                          levels = c("item_only", "task_only", "Both_item_task"))

report("Total participants: ", n_distinct(metrics$participant))
report("Groups: ", paste(levels(metrics$group), collapse = ", "))
report("Retrieval trials: ", nrow(retrieval))
report("Participant × Position rows: ", nrow(metrics))

############################################################################
# SECTION A – DESCRIPTIVE STATISTICS
############################################################################
report("\n================================================================")
report("  SECTION A: DESCRIPTIVE STATISTICS")
report("================================================================\n")

# ── A1. Overall REC & LDI per group ───────────────────────────────────────
overall <- metrics %>%
  group_by(group) %>%
  summarise(
    n            = n_distinct(participant),
    REC_mean     = mean(REC, na.rm = TRUE),
    REC_sd       = sd(REC, na.rm = TRUE),
    REC_median   = median(REC, na.rm = TRUE),
    REC_IQR      = IQR(REC, na.rm = TRUE),
    LDI_mean     = mean(LDI, na.rm = TRUE),
    LDI_sd       = sd(LDI, na.rm = TRUE),
    LDI_median   = median(LDI, na.rm = TRUE),
    LDI_IQR      = IQR(LDI, na.rm = TRUE),
    .groups      = "drop"
  )

report("── A1. Overall REC & LDI by Group ──")
report(paste(capture.output(print(as.data.frame(overall), row.names = FALSE)), collapse = "\n"))

# ── A2. REC & LDI by Boundary Position × Group ───────────────────────────
pos_stats <- metrics %>%
  group_by(group, boundary_position) %>%
  summarise(
    n          = n(),
    REC_mean   = round(mean(REC, na.rm = TRUE), 4),
    REC_sd     = round(sd(REC, na.rm = TRUE), 4),
    LDI_mean   = round(mean(LDI, na.rm = TRUE), 4),
    LDI_sd     = round(sd(LDI, na.rm = TRUE), 4),
    .groups    = "drop"
  )

report("\n── A2. REC & LDI by Boundary Position × Group ──")
report(paste(capture.output(print(as.data.frame(pos_stats), row.names = FALSE)), collapse = "\n"))

# ── A3. Response Proportions ──────────────────────────────────────────────
resp_props <- retrieval %>%
  filter(stimulus_type %in% c("Target", "Lure", "Foil")) %>%
  group_by(group, stimulus_type, response) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(group, stimulus_type) %>%
  mutate(prop = round(n / sum(n), 4)) %>%
  ungroup()

report("\n── A3. Response Proportions by Stimulus Type × Group ──")
report(paste(capture.output(print(as.data.frame(resp_props), row.names = FALSE)), collapse = "\n"))

# ── A4. Retrieval RT descriptives ─────────────────────────────────────────
rt_desc <- retrieval %>%
  filter(stimulus_type %in% c("Target", "Lure", "Foil"), !is.na(rt)) %>%
  group_by(group, stimulus_type) %>%
  summarise(
    mean_rt   = round(mean(rt, na.rm = TRUE), 3),
    sd_rt     = round(sd(rt, na.rm = TRUE), 3),
    median_rt = round(median(rt, na.rm = TRUE), 3),
    .groups   = "drop"
  )

report("\n── A4. Retrieval RT by Stimulus Type × Group ──")
report(paste(capture.output(print(as.data.frame(rt_desc), row.names = FALSE)), collapse = "\n"))

# ── A5. Encoding RT descriptives ──────────────────────────────────────────
report("\n── A5. Encoding RT Summary by Group ──")
enc_rt_group <- enc_rt %>%
  group_by(group) %>%
  summarise(
    n             = n(),
    mean_enc_rt   = round(mean(mean_encoding_rt, na.rm = TRUE), 3),
    sd_enc_rt     = round(sd(mean_encoding_rt, na.rm = TRUE), 3),
    median_enc_rt = round(median(mean_encoding_rt, na.rm = TRUE), 3),
    .groups       = "drop"
  )
report(paste(capture.output(print(as.data.frame(enc_rt_group), row.names = FALSE)), collapse = "\n"))

# ── A6. Lure Bin Descriptives ─────────────────────────────────────────────
lure_bin_desc <- lure_bins %>%
  group_by(group, lure_bin) %>%
  summarise(
    mean_p_sim  = round(mean(p_similar, na.rm = TRUE), 4),
    sd_p_sim    = round(sd(p_similar, na.rm = TRUE), 4),
    .groups     = "drop"
  )

report("\n── A6. P('similar'|Lure) by Lure Bin × Group ──")
report(paste(capture.output(print(as.data.frame(lure_bin_desc), row.names = FALSE)), collapse = "\n"))

# ── A7. Full psych::describe for key metrics ──────────────────────────────
report("\n── A7. Detailed Descriptive Statistics (psych::describe) ──")
report("\n  --- REC by Boundary Position ---")
for (pos in c("pre", "mid", "post")) {
  d <- metrics %>% filter(boundary_position == pos) %>% pull(REC)
  report(paste0("  Position: ", pos))
  report(paste(capture.output(print(round(describe(d), 4))), collapse = "\n"))
}
report("\n  --- LDI by Boundary Position ---")
for (pos in c("pre", "mid", "post")) {
  d <- metrics %>% filter(boundary_position == pos) %>% pull(LDI)
  report(paste0("  Position: ", pos))
  report(paste(capture.output(print(round(describe(d), 4))), collapse = "\n"))
}


############################################################################
# SECTION B – VISUALISATIONS
############################################################################
report("\n================================================================")
report("  SECTION B: VISUALISATIONS")
report("================================================================\n")

theme_mst <- theme_minimal(base_size = 13) +
  theme(
    plot.title   = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5, colour = "grey40"),
    legend.position = "bottom"
  )

# ── B1. REC by Boundary Position (violin + box) ──────────────────────────
p1 <- ggplot(metrics, aes(x = boundary_position, y = REC, fill = boundary_position)) +
  geom_violin(alpha = 0.4, width = 0.8) +
  geom_boxplot(width = 0.15, outlier.shape = 21) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "red") +
  facet_wrap(~group) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Recognition Memory (REC) by Boundary Position",
       subtitle = "Red diamond = mean; Box = median ± IQR",
       x = "Boundary Position", y = "REC") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B1_REC_by_position.png"), p1, width = 10, height = 5, dpi = 300)
report("  Saved: B1_REC_by_position.png")

# ── B2. LDI by Boundary Position (violin + box) ──────────────────────────
p2 <- ggplot(metrics, aes(x = boundary_position, y = LDI, fill = boundary_position)) +
  geom_violin(alpha = 0.4, width = 0.8) +
  geom_boxplot(width = 0.15, outlier.shape = 21) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "red") +
  facet_wrap(~group) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Lure Discrimination Index (LDI) by Boundary Position",
       subtitle = "Red diamond = mean; Box = median ± IQR",
       x = "Boundary Position", y = "LDI") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B2_LDI_by_position.png"), p2, width = 10, height = 5, dpi = 300)
report("  Saved: B2_LDI_by_position.png")

# ── B3. Histograms of REC & LDI distributions ────────────────────────────
p3a <- ggplot(metrics, aes(x = REC, fill = boundary_position)) +
  geom_histogram(bins = 25, alpha = 0.6, position = "identity") +
  facet_grid(group ~ boundary_position) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Distribution of REC", x = "REC", y = "Count") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B3a_REC_histograms.png"), p3a, width = 12, height = 7, dpi = 300)

p3b <- ggplot(metrics, aes(x = LDI, fill = boundary_position)) +
  geom_histogram(bins = 25, alpha = 0.6, position = "identity") +
  facet_grid(group ~ boundary_position) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Distribution of LDI", x = "LDI", y = "Count") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B3b_LDI_histograms.png"), p3b, width = 12, height = 7, dpi = 300)
report("  Saved: B3a_REC_histograms.png, B3b_LDI_histograms.png")

# ── B4. Lure Bin Accuracy Curve ───────────────────────────────────────────
lure_bin_summary <- lure_bins %>%
  group_by(group, lure_bin) %>%
  summarise(
    mean_p = mean(p_similar, na.rm = TRUE),
    se_p   = sd(p_similar, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

p4 <- ggplot(lure_bin_summary, aes(x = factor(lure_bin), y = mean_p,
                                    colour = group, group = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_p - se_p, ymax = mean_p + se_p), width = 0.15) +
  scale_colour_brewer(palette = "Dark2") +
  labs(title = "Lure Bin Accuracy: P('similar' | Lure) by Similarity Bin",
       subtitle = "Bin 1 = most similar to target, Bin 5 = most different",
       x = "Lure Bin (similarity)", y = "P('similar' | Lure)",
       colour = "Group") +
  theme_mst
ggsave(file.path(PLOTS, "B4_lure_bin_curve.png"), p4, width = 8, height = 5, dpi = 300)
report("  Saved: B4_lure_bin_curve.png")

# ── B5. Mean REC & LDI line plot with CIs ─────────────────────────────────
pos_summary <- metrics %>%
  group_by(group, boundary_position) %>%
  summarise(
    REC_mean = mean(REC, na.rm = TRUE),
    REC_se   = sd(REC, na.rm = TRUE) / sqrt(n()),
    LDI_mean = mean(LDI, na.rm = TRUE),
    LDI_se   = sd(LDI, na.rm = TRUE) / sqrt(n()),
    .groups  = "drop"
  )

p5a <- ggplot(pos_summary, aes(x = boundary_position, y = REC_mean,
                                colour = group, group = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = REC_mean - REC_se, ymax = REC_mean + REC_se), width = 0.12) +
  scale_colour_brewer(palette = "Dark2") +
  labs(title = "Mean REC by Boundary Position",
       subtitle = "Error bars = ±1 SE",
       x = "Boundary Position", y = "Mean REC", colour = "Group") +
  theme_mst
ggsave(file.path(PLOTS, "B5a_REC_line.png"), p5a, width = 7, height = 5, dpi = 300)

p5b <- ggplot(pos_summary, aes(x = boundary_position, y = LDI_mean,
                                colour = group, group = group)) +
  geom_line(linewidth = 1) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = LDI_mean - LDI_se, ymax = LDI_mean + LDI_se), width = 0.12) +
  scale_colour_brewer(palette = "Dark2") +
  labs(title = "Mean LDI by Boundary Position",
       subtitle = "Error bars = ±1 SE",
       x = "Boundary Position", y = "Mean LDI", colour = "Group") +
  theme_mst
ggsave(file.path(PLOTS, "B5b_LDI_line.png"), p5b, width = 7, height = 5, dpi = 300)
report("  Saved: B5a_REC_line.png, B5b_LDI_line.png")

# ── B6. Retrieval RT by Stimulus Type ─────────────────────────────────────
rt_data <- retrieval %>%
  filter(stimulus_type %in% c("Target", "Lure", "Foil"), !is.na(rt))

p6 <- ggplot(rt_data, aes(x = stimulus_type, y = rt, fill = stimulus_type)) +
  geom_violin(alpha = 0.4) +
  geom_boxplot(width = 0.15, outlier.size = 0.5) +
  facet_wrap(~group) +
  coord_cartesian(ylim = c(0, 10)) +
  scale_fill_brewer(palette = "Pastel1") +
  labs(title = "Retrieval RT by Stimulus Type",
       x = "Stimulus Type", y = "RT (seconds)") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B6_retrieval_RT.png"), p6, width = 10, height = 5, dpi = 300)
report("  Saved: B6_retrieval_RT.png")

# ── B7. Encoding RT by Group ─────────────────────────────────────────────
p7 <- ggplot(enc_rt, aes(x = group, y = mean_encoding_rt, fill = group)) +
  geom_violin(alpha = 0.4) +
  geom_boxplot(width = 0.15) +
  stat_summary(fun = mean, geom = "point", shape = 18, size = 3, colour = "red") +
  scale_fill_brewer(palette = "Pastel2") +
  labs(title = "Mean Encoding RT by Group",
       x = "Group", y = "Mean Encoding RT (s)") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B7_encoding_RT.png"), p7, width = 7, height = 5, dpi = 300)
report("  Saved: B7_encoding_RT.png")

# ── B8. Scatterplot: Encoding RT vs Overall LDI ──────────────────────────
overall_ldi <- metrics %>%
  group_by(participant, group) %>%
  summarise(overall_LDI = mean(overall_LDI, na.rm = TRUE), .groups = "drop")

rt_ldi <- inner_join(enc_rt, overall_ldi, by = c("participant", "group"))

p8 <- ggplot(rt_ldi, aes(x = mean_encoding_rt, y = overall_LDI, colour = group)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = TRUE, linewidth = 0.8) +
  facet_wrap(~group) +
  scale_colour_brewer(palette = "Dark2") +
  labs(title = "Encoding RT vs. Lure Discrimination (LDI)",
       subtitle = "Does longer encoding predict better mnemonic discrimination?",
       x = "Mean Encoding RT (s)", y = "Overall LDI") +
  theme_mst + theme(legend.position = "none")
ggsave(file.path(PLOTS, "B8_RT_vs_LDI.png"), p8, width = 10, height = 5, dpi = 300)
report("  Saved: B8_RT_vs_LDI.png")


############################################################################
# SECTION C – NORMALITY CHECKS
############################################################################
report("\n================================================================")
report("  SECTION C: NORMALITY CHECKS")
report("================================================================\n")

report("── C1. Shapiro-Wilk Tests on REC by Position × Group ──")
shapiro_rec <- metrics %>%
  group_by(group, boundary_position) %>%
  summarise(
    W      = shapiro.test(REC)$statistic,
    p      = shapiro.test(REC)$p.value,
    normal = ifelse(shapiro.test(REC)$p.value > 0.05, "Yes", "No"),
    .groups = "drop"
  ) %>%
  mutate(W = round(W, 4), p = round(p, 4))
report(paste(capture.output(print(as.data.frame(shapiro_rec), row.names = FALSE)), collapse = "\n"))

report("\n── C2. Shapiro-Wilk Tests on LDI by Position × Group ──")
shapiro_ldi <- metrics %>%
  group_by(group, boundary_position) %>%
  summarise(
    W      = shapiro.test(LDI)$statistic,
    p      = shapiro.test(LDI)$p.value,
    normal = ifelse(shapiro.test(LDI)$p.value > 0.05, "Yes", "No"),
    .groups = "drop"
  ) %>%
  mutate(W = round(W, 4), p = round(p, 4))
report(paste(capture.output(print(as.data.frame(shapiro_ldi), row.names = FALSE)), collapse = "\n"))

# ── C3. QQ Plots ──────────────────────────────────────────────────────────
# REC QQ
p_qq_rec <- ggplot(metrics, aes(sample = REC)) +
  stat_qq(size = 1, alpha = 0.5) +
  stat_qq_line(colour = "red") +
  facet_grid(group ~ boundary_position) +
  labs(title = "QQ Plots: REC by Position × Group") +
  theme_mst
ggsave(file.path(PLOTS, "C3a_QQ_REC.png"), p_qq_rec, width = 10, height = 8, dpi = 300)

# LDI QQ
p_qq_ldi <- ggplot(metrics, aes(sample = LDI)) +
  stat_qq(size = 1, alpha = 0.5) +
  stat_qq_line(colour = "red") +
  facet_grid(group ~ boundary_position) +
  labs(title = "QQ Plots: LDI by Position × Group") +
  theme_mst
ggsave(file.path(PLOTS, "C3b_QQ_LDI.png"), p_qq_ldi, width = 10, height = 8, dpi = 300)
report("  Saved: C3a_QQ_REC.png, C3b_QQ_LDI.png")


############################################################################
# SECTION D – INFERENTIAL STATISTICS (with p-value corrections)
############################################################################
report("\n================================================================")
report("  SECTION D: INFERENTIAL STATISTICS")
report("================================================================\n")

report("──────────────────────────────────────────────────────────────")
report("  NOTE ON MULTIPLE COMPARISON CORRECTIONS")
report("──────────────────────────────────────────────────────────────")
report("  • Bonferroni correction: p_adj = p × k (number of tests)")
report("    Conservative; controls family-wise error rate (FWER).")
report("  • Benjamini-Hochberg (BH): controls false discovery rate")
report("    (FDR). Less conservative, often preferred for exploration.")
report("  • We run both and report each alongside the raw p-value.\n")

# ═══════════════════════════════════════════════════════════════════
# D1. PAIRED T-TESTS: Boundary Position Effects on REC
#     Test the "Blind Spot" hypothesis: post vs mid
#     and pre vs mid for each group
# ═══════════════════════════════════════════════════════════════════
report("── D1. Paired t-tests: REC Boundary Effects ──")
report("  Testing within-subject differences (post-boundary 'Blind Spot',")
report("  pre-boundary enhancement) using mid-event as baseline.\n")

# Pivot wide for paired tests
rec_wide <- metrics %>%
  select(participant, group, boundary_position, REC) %>%
  pivot_wider(names_from = boundary_position, values_from = REC,
              names_prefix = "REC_")

rec_tests <- list()
for (g in levels(metrics$group)) {
  d <- rec_wide %>% filter(group == g)
  
  # Post vs Mid (Blind Spot: expect post < mid)
  t_post <- t.test(d$REC_post, d$REC_mid, paired = TRUE)
  d_post <- cohens_d(d$REC_post, d$REC_mid, paired = TRUE)
  # Also Wilcoxon as non-parametric alternative
  w_post <- wilcox.test(d$REC_post, d$REC_mid, paired = TRUE)
  
  # Pre vs Mid
  t_pre <- t.test(d$REC_pre, d$REC_mid, paired = TRUE)
  d_pre <- cohens_d(d$REC_pre, d$REC_mid, paired = TRUE)
  w_pre <- wilcox.test(d$REC_pre, d$REC_mid, paired = TRUE)
  
  rec_tests[[paste0(g, "_post_vs_mid")]] <- list(
    group = g, comparison = "post vs mid",
    t = round(t_post$statistic, 4), df = t_post$parameter,
    p_raw = t_post$p.value, d = round(d_post$Cohens_d, 4),
    wilcox_p = w_post$p.value
  )
  rec_tests[[paste0(g, "_pre_vs_mid")]] <- list(
    group = g, comparison = "pre vs mid",
    t = round(t_pre$statistic, 4), df = t_pre$parameter,
    p_raw = t_pre$p.value, d = round(d_pre$Cohens_d, 4),
    wilcox_p = w_pre$p.value
  )
}

rec_results <- bind_rows(lapply(rec_tests, as.data.frame))
# Apply corrections across all 6 REC tests
rec_results$p_bonferroni <- p.adjust(rec_results$p_raw, method = "bonferroni")
rec_results$p_BH         <- p.adjust(rec_results$p_raw, method = "BH")
rec_results$wilcox_p_bonf <- p.adjust(rec_results$wilcox_p, method = "bonferroni")
rec_results$wilcox_p_BH   <- p.adjust(rec_results$wilcox_p, method = "BH")

# Round for display
rec_display <- rec_results %>%
  mutate(across(starts_with("p_") | starts_with("wilcox_p"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(rec_display), row.names = FALSE)), collapse = "\n"))

# ═══════════════════════════════════════════════════════════════════
# D2. PAIRED T-TESTS: Boundary Position Effects on LDI
#     Test the "Snapshot" hypothesis: pre vs mid
# ═══════════════════════════════════════════════════════════════════
report("\n── D2. Paired t-tests: LDI Boundary Effects ──")
report("  Testing the 'Snapshot' hypothesis: enhanced LDI at pre-boundary.\n")

ldi_wide <- metrics %>%
  select(participant, group, boundary_position, LDI) %>%
  pivot_wider(names_from = boundary_position, values_from = LDI,
              names_prefix = "LDI_")

ldi_tests <- list()
for (g in levels(metrics$group)) {
  d <- ldi_wide %>% filter(group == g)
  
  # Pre vs Mid (Snapshot: expect pre > mid)
  t_pre <- t.test(d$LDI_pre, d$LDI_mid, paired = TRUE)
  d_pre <- cohens_d(d$LDI_pre, d$LDI_mid, paired = TRUE)
  w_pre <- wilcox.test(d$LDI_pre, d$LDI_mid, paired = TRUE)
  
  # Post vs Mid
  t_post <- t.test(d$LDI_post, d$LDI_mid, paired = TRUE)
  d_post <- cohens_d(d$LDI_post, d$LDI_mid, paired = TRUE)
  w_post <- wilcox.test(d$LDI_post, d$LDI_mid, paired = TRUE)
  
  ldi_tests[[paste0(g, "_pre_vs_mid")]] <- list(
    group = g, comparison = "pre vs mid",
    t = round(t_pre$statistic, 4), df = t_pre$parameter,
    p_raw = t_pre$p.value, d = round(d_pre$Cohens_d, 4),
    wilcox_p = w_pre$p.value
  )
  ldi_tests[[paste0(g, "_post_vs_mid")]] <- list(
    group = g, comparison = "post vs mid",
    t = round(t_post$statistic, 4), df = t_post$parameter,
    p_raw = t_post$p.value, d = round(d_post$Cohens_d, 4),
    wilcox_p = w_post$p.value
  )
}

ldi_results <- bind_rows(lapply(ldi_tests, as.data.frame))
ldi_results$p_bonferroni <- p.adjust(ldi_results$p_raw, method = "bonferroni")
ldi_results$p_BH         <- p.adjust(ldi_results$p_raw, method = "BH")
ldi_results$wilcox_p_bonf <- p.adjust(ldi_results$wilcox_p, method = "bonferroni")
ldi_results$wilcox_p_BH   <- p.adjust(ldi_results$wilcox_p, method = "BH")

ldi_display <- ldi_results %>%
  mutate(across(starts_with("p_") | starts_with("wilcox_p"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(ldi_display), row.names = FALSE)), collapse = "\n"))

# ═══════════════════════════════════════════════════════════════════
# D3. BASELINED DIFFERENCE SCORES: One-sample t-tests against 0
#     REC_diff = REC_post - REC_mid (Blind Spot < 0?)
#     LDI_diff = LDI_pre  - LDI_mid (Snapshot > 0?)
# ═══════════════════════════════════════════════════════════════════
report("\n── D3. One-sample t-tests on Baselined Difference Scores ──")
report("  REC_diff = REC_post − REC_mid (Blind Spot: expect < 0)")
report("  LDI_diff = LDI_pre  − LDI_mid (Snapshot: expect > 0)\n")

diff_tests <- list()
for (g in levels(metrics$group)) {
  d_rec <- rec_wide %>% filter(group == g) %>% mutate(diff = REC_post - REC_mid)
  d_ldi <- ldi_wide %>% filter(group == g) %>% mutate(diff = LDI_pre  - LDI_mid)
  
  t_rec <- t.test(d_rec$diff, mu = 0)
  t_ldi <- t.test(d_ldi$diff, mu = 0)
  
  diff_tests[[paste0(g, "_REC_blind_spot")]] <- data.frame(
    group = g, metric = "REC (post-mid)", mean_diff = round(mean(d_rec$diff), 4),
    t = round(t_rec$statistic, 4), p_raw = t_rec$p.value
  )
  diff_tests[[paste0(g, "_LDI_snapshot")]] <- data.frame(
    group = g, metric = "LDI (pre-mid)", mean_diff = round(mean(d_ldi$diff), 4),
    t = round(t_ldi$statistic, 4), p_raw = t_ldi$p.value
  )
}

diff_results <- bind_rows(diff_tests)
diff_results$p_bonferroni <- p.adjust(diff_results$p_raw, method = "bonferroni")
diff_results$p_BH         <- p.adjust(diff_results$p_raw, method = "BH")
diff_results <- diff_results %>% mutate(across(starts_with("p_"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(diff_results), row.names = FALSE)), collapse = "\n"))

# ═══════════════════════════════════════════════════════════════════
# D4. CORRELATION: Encoding RT vs LDI
# ═══════════════════════════════════════════════════════════════════
report("\n── D4. Correlation: Encoding RT vs. Overall LDI ──")

cor_tests <- list()
for (g in levels(metrics$group)) {
  d <- rt_ldi %>% filter(group == g)
  if (nrow(d) < 3) next
  
  # Pearson
  cp <- cor.test(d$mean_encoding_rt, d$overall_LDI, method = "pearson")
  # Spearman
  cs <- cor.test(d$mean_encoding_rt, d$overall_LDI, method = "spearman")
  
  cor_tests[[paste0(g, "_pearson")]] <- data.frame(
    group = g, method = "Pearson",
    r = round(cp$estimate, 4), p_raw = cp$p.value
  )
  cor_tests[[paste0(g, "_spearman")]] <- data.frame(
    group = g, method = "Spearman",
    r = round(cs$estimate, 4), p_raw = cs$p.value
  )
}

cor_results <- bind_rows(cor_tests)
cor_results$p_bonferroni <- p.adjust(cor_results$p_raw, method = "bonferroni")
cor_results$p_BH         <- p.adjust(cor_results$p_raw, method = "BH")
cor_results <- cor_results %>% mutate(across(starts_with("p_"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(cor_results), row.names = FALSE)), collapse = "\n"))

# ═══════════════════════════════════════════════════════════════════
# D5. CORRELATION: Encoding RT vs REC
# ═══════════════════════════════════════════════════════════════════
report("\n── D5. Correlation: Encoding RT vs. Overall REC ──")

overall_rec <- metrics %>%
  group_by(participant, group) %>%
  summarise(overall_REC = mean(overall_REC, na.rm = TRUE), .groups = "drop")
rt_rec <- inner_join(enc_rt, overall_rec, by = c("participant", "group"))

cor2_tests <- list()
for (g in levels(metrics$group)) {
  d <- rt_rec %>% filter(group == g)
  if (nrow(d) < 3) next
  cp <- cor.test(d$mean_encoding_rt, d$overall_REC, method = "pearson")
  cs <- cor.test(d$mean_encoding_rt, d$overall_REC, method = "spearman")
  cor2_tests[[paste0(g, "_pearson")]] <- data.frame(
    group = g, method = "Pearson",
    r = round(cp$estimate, 4), p_raw = cp$p.value
  )
  cor2_tests[[paste0(g, "_spearman")]] <- data.frame(
    group = g, method = "Spearman",
    r = round(cs$estimate, 4), p_raw = cs$p.value
  )
}

cor2_results <- bind_rows(cor2_tests)
cor2_results$p_bonferroni <- p.adjust(cor2_results$p_raw, method = "bonferroni")
cor2_results$p_BH         <- p.adjust(cor2_results$p_raw, method = "BH")
cor2_results <- cor2_results %>% mutate(across(starts_with("p_"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(cor2_results), row.names = FALSE)), collapse = "\n"))

# ═══════════════════════════════════════════════════════════════════
# D6. RETRIEVAL RT: Paired t-tests by boundary position
#     "Speed Bump" effect: post-boundary RT > mid-event RT
# ═══════════════════════════════════════════════════════════════════
report("\n── D6. Retrieval RT 'Speed Bump': Post vs Mid ──")

# Mean RT per participant per position (targets + lures only, excluding foils/scenes)
rt_by_pos <- retrieval %>%
  filter(stimulus_type %in% c("Target", "Lure"),
         boundary_position %in% c("pre", "mid", "post"),
         !is.na(rt)) %>%
  group_by(participant, group, boundary_position) %>%
  summarise(mean_rt = mean(rt, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = boundary_position, values_from = mean_rt,
              names_prefix = "RT_")

rt_tests <- list()
for (g in levels(metrics$group)) {
  d <- rt_by_pos %>% filter(group == g) %>% drop_na()
  if (nrow(d) < 3) next
  
  t_speed <- t.test(d$RT_post, d$RT_mid, paired = TRUE)
  d_speed <- cohens_d(d$RT_post, d$RT_mid, paired = TRUE)
  w_speed <- wilcox.test(d$RT_post, d$RT_mid, paired = TRUE)
  
  rt_tests[[g]] <- data.frame(
    group = g, comparison = "RT_post vs RT_mid",
    mean_diff = round(mean(d$RT_post - d$RT_mid, na.rm = TRUE), 4),
    t = round(t_speed$statistic, 4), df = t_speed$parameter,
    p_raw = t_speed$p.value,
    d = round(d_speed$Cohens_d, 4),
    wilcox_p = w_speed$p.value
  )
}

rt_results <- bind_rows(rt_tests)
rt_results$p_bonferroni <- p.adjust(rt_results$p_raw, method = "bonferroni")
rt_results$p_BH         <- p.adjust(rt_results$p_raw, method = "BH")
rt_results$wilcox_p_bonf <- p.adjust(rt_results$wilcox_p, method = "bonferroni")
rt_results$wilcox_p_BH   <- p.adjust(rt_results$wilcox_p, method = "BH")
rt_results <- rt_results %>% mutate(across(starts_with("p_") | starts_with("wilcox_p"), ~round(., 5)))
report(paste(capture.output(print(as.data.frame(rt_results), row.names = FALSE)), collapse = "\n"))

# Retrieval RT line plot
rt_line_data <- retrieval %>%
  filter(stimulus_type %in% c("Target", "Lure"),
         boundary_position %in% c("pre", "mid", "post"), !is.na(rt)) %>%
  group_by(group, boundary_position) %>%
  summarise(mean_rt = mean(rt), se_rt = sd(rt)/sqrt(n()), .groups = "drop")

p_rt_line <- ggplot(rt_line_data, aes(x = boundary_position, y = mean_rt,
                                       colour = group, group = group)) +
  geom_line(linewidth = 1) + geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_rt - se_rt, ymax = mean_rt + se_rt), width = 0.1) +
  scale_colour_brewer(palette = "Dark2") +
  labs(title = "Retrieval RT 'Speed Bump' by Boundary Position",
       x = "Boundary Position", y = "Mean RT (s)", colour = "Group") +
  theme_mst
ggsave(file.path(PLOTS, "D6_RT_speed_bump.png"), p_rt_line, width = 7, height = 5, dpi = 300)
report("  Saved: D6_RT_speed_bump.png")

# ═══════════════════════════════════════════════════════════════════
# D7. GRAND SUMMARY OF ALL P-VALUES
# ═══════════════════════════════════════════════════════════════════
report("\n══════════════════════════════════════════════════════════════")
report("  D7. MASTER P-VALUE SUMMARY (all tests pooled)")
report("══════════════════════════════════════════════════════════════\n")

all_p <- c(
  rec_results$p_raw, ldi_results$p_raw, diff_results$p_raw,
  cor_results$p_raw, cor2_results$p_raw, rt_results$p_raw
)
all_labels <- c(
  paste("REC", rec_results$group, rec_results$comparison),
  paste("LDI", ldi_results$group, ldi_results$comparison),
  paste("Diff", diff_results$group, diff_results$metric),
  paste("Cor_RT_LDI", cor_results$group, cor_results$method),
  paste("Cor_RT_REC", cor2_results$group, cor2_results$method),
  paste("RT_SpeedBump", rt_results$group)
)

master <- data.frame(
  test       = all_labels,
  p_raw      = round(all_p, 6),
  p_bonf     = round(p.adjust(all_p, method = "bonferroni"), 6),
  p_BH       = round(p.adjust(all_p, method = "BH"), 6),
  sig_raw    = ifelse(all_p < 0.05, "*", ""),
  sig_bonf   = ifelse(p.adjust(all_p, method = "bonferroni") < 0.05, "*", ""),
  sig_BH     = ifelse(p.adjust(all_p, method = "BH") < 0.05, "*", "")
)

report(paste(capture.output(print(master, row.names = FALSE)), collapse = "\n"))
report(paste0("\n  Total tests: ", length(all_p)))
report(paste0("  Significant (raw α=0.05): ", sum(all_p < 0.05)))
report(paste0("  Significant (Bonferroni): ", sum(p.adjust(all_p, "bonferroni") < 0.05)))
report(paste0("  Significant (BH FDR):    ", sum(p.adjust(all_p, "BH") < 0.05)))


############################################################################
# CLOSE
############################################################################
report("\n================================================================")
report("  Analysis complete. All output saved to:")
report(paste0("    Report: ", REPORT))
report(paste0("    Plots:  ", PLOTS, "/"))
report("================================================================")

close(sink_file)
cat("\n✅ Full report written to:", REPORT, "\n")
cat("✅ All plots saved to:", PLOTS, "\n")
