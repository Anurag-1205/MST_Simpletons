# MST Experiment – Report 1: Complete Analysis Walkthrough

## Study Overview
This analysis investigates how **event boundaries** affect memory in the **Mnemonic Similarity Task (MST)**, replicating Morse et al. (2023). Participants viewed sequences of objects separated by scene images (boundaries), then completed a recognition test where they classified images as "Old", "Similar", or "New".

**159 participants** across 3 experimental groups — `item_only` (n=56), `task_only` (n=53), `Both_item_task` (n=50–52).

---

## A. Descriptive Statistics

### Key Memory Metrics

| Metric | Formula | Measures |
|---|---|---|
| **REC** | P("old"\|Target) − P("old"\|Foil) | Recognition memory, corrected for bias |
| **LDI** | P("similar"\|Lure) − P("similar"\|Foil) | Pattern separation / lure discrimination |

**Why these metrics?** Raw hit rates are confounded by response bias. REC subtracts false alarms to foils, giving a bias-corrected recognition score. LDI isolates the ability to detect similar-but-not-identical items (pattern separation).

### REC & LDI by Boundary Position × Group

Key hypotheses tested:
- **Blind Spot** (post-boundary): Items after a boundary have *reduced* REC (memory impairment)
- **Snapshot** (pre-boundary): Items before a boundary have *enhanced* LDI (finer-grained memory)

### Visualisations

````carousel
![REC by Boundary Position — Violin + box plots show the distribution of recognition memory for each position (pre/mid/post) across groups. The red diamond indicates the mean.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B1_REC_by_position.png)
<!-- slide -->
![LDI by Boundary Position — Same layout for lure discrimination. Higher LDI = better pattern separation ability.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B2_LDI_by_position.png)
<!-- slide -->
![Mean REC Line Plot — Group means with ±1 SE error bars showing the trajectory of recognition memory across boundary positions.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B5a_REC_line.png)
<!-- slide -->
![Mean LDI Line Plot — Group means with ±1 SE error bars for lure discrimination.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B5b_LDI_line.png)
````

### Distribution & Normality Checks

````carousel
![REC Histograms — Distribution of REC scores faceted by group × position. Used to assess skewness and check for outliers.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B3a_REC_histograms.png)
<!-- slide -->
![LDI Histograms — Same layout for LDI distributions.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B3b_LDI_histograms.png)
<!-- slide -->
![QQ Plots for REC — Points should fall on the red line if data is normally distributed. Deviations in tails indicate non-normality.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/C3a_QQ_REC.png)
<!-- slide -->
![QQ Plots for LDI — Similar normality check for lure discrimination scores.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/C3b_QQ_LDI.png)
````

### Lure Bin Analysis & Reaction Times

````carousel
![Lure Bin Accuracy Curve — P("similar"|Lure) across 5 similarity bins. Bin 1 = most similar lures (hardest). The downward slope shows classic pattern separation — easier discrimination for less similar lures.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B4_lure_bin_curve.png)
<!-- slide -->
![Retrieval RT by Stimulus Type — Violin + box plots showing how long participants took to respond to targets, lures, and foils. Lures typically elicit longer RTs due to decision difficulty.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B6_retrieval_RT.png)
<!-- slide -->
![Encoding RT by Group — Between-group differences in encoding viewing time.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B7_encoding_RT.png)
<!-- slide -->
![Encoding RT vs LDI Scatterplot — Tests whether longer encoding time predicts better lure discrimination. Separate regression lines per group.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/B8_RT_vs_LDI.png)
<!-- slide -->
![Retrieval RT Speed Bump — Mean retrieval RT by boundary position. Tests whether post-boundary items take longer to retrieve.](/Users/srushtipekamwar/.gemini/antigravity/brain/ba21c4f8-f3ec-4048-a8bb-0b686a05c9d1/D6_RT_speed_bump.png)
````

---

## B. Normality Checks

**Method:** Shapiro-Wilk test (null = normality) + QQ plots for visual inspection.

**Why?** Determines whether parametric (t-test) or non-parametric (Wilcoxon) tests are appropriate. We ran **both** to be safe.

**Result:** Several group × position cells showed significant departures from normality (p < 0.05). Therefore, we report both parametric (paired t-test with Cohen's d) and non-parametric (Wilcoxon signed-rank) results. The conclusions are consistent across both approaches.

---

## C. Inferential Statistics

### Why p-value corrections?

Running multiple tests on the same dataset inflates Type I error rate. With 33 tests at α = 0.05, we'd expect ~1.65 false positives by chance. To address this:

| Correction | Goal | Method |
|---|---|---|
| **Bonferroni** | Controls family-wise error rate (FWER) | p_adj = p × k (very conservative) |
| **Benjamini-Hochberg** | Controls false discovery rate (FDR) | Rank-ordered adjustment (less conservative) |

Both are applied and reported.

---

### C1. Blind Spot Effect (REC: post vs mid)

**What we tested:** Do post-boundary items have lower recognition memory than mid-event items? (Paired t-tests within each group)

| Group | Mean Diff | t | p (raw) | p (Bonf.) | p (BH) | Cohen's d | Result |
|---|---|---|---|---|---|---|---|
| item_only | −0.055 | −1.86 | 0.068 | 1.000 | 0.365 | −0.25 | Trend only |
| task_only | −0.038 | −1.80 | 0.077 | 1.000 | 0.365 | −0.25 | Trend only |
| **Both_item_task** | **−0.124** | **−4.12** | **0.0001** | **0.005** | **0.002** | **−0.58** | **✅ Significant** |

> [!IMPORTANT]
> The **Blind Spot effect is significant in the Both_item_task group** (p = 0.00014, survives both Bonferroni and BH correction). Post-boundary items show a medium-sized memory impairment (d = −0.58). The item_only and task_only groups show trends in the same direction but do not reach significance.

**Why this test?** The paired design controls for individual differences in overall memory ability. REC_post − REC_mid isolates the boundary effect while subtracting the participant's own baseline.

---

### C2. Snapshot Effect (LDI: pre vs mid)

**What we tested:** Do pre-boundary items have higher lure discrimination than mid-event items?

| Group | Mean Diff | t | p (raw) | p (Bonf.) | p (BH) | Cohen's d | Result |
|---|---|---|---|---|---|---|---|
| item_only | −0.008 | −0.25 | 0.800 | 1.000 | 0.800 | −0.03 | Not significant |
| task_only | +0.019 | 0.99 | 0.326 | 1.000 | 0.671 | 0.14 | Not significant |
| Both_item_task | +0.011 | 0.38 | 0.706 | 1.000 | 0.852 | 0.05 | Not significant |

**Interpretation:** No evidence for a Snapshot effect in any group. Pre-boundary items do not show enhanced lure discrimination relative to mid-event items.

---

### C3. Encoding RT vs Memory Correlations

**What we tested:** Does spending more time viewing stimuli during encoding predict better memory?

- **RT → LDI:** No significant correlations in any group (all p > 0.13)
- **RT → REC:** One marginally significant negative correlation in Both_item_task (r = −0.29, raw p = 0.047) — but this does **not survive BH correction** (p_BH = 0.365)

**Interpretation:** Encoding viewing time does not reliably predict memory performance in this dataset.

---

### C4. Retrieval RT Speed Bump (post vs mid)

**What we tested:** Are post-boundary items responded to more slowly during retrieval?

| Group | Mean Diff | t | p (raw) | Result |
|---|---|---|---|---|
| item_only | −0.091 | −0.76 | 0.452 | Not significant |
| task_only | −0.036 | −0.61 | 0.542 | Not significant |
| Both_item_task | −0.026 | −0.27 | 0.792 | Not significant |

**Interpretation:** No evidence for a retrieval speed bump effect. Post-boundary items are not responded to significantly slower.

---

### C5. Master p-value Summary

Across all **33 tests** conducted:

| Level | # Significant |
|---|---|
| Raw (α = 0.05) | 3 |
| Bonferroni-corrected | **2** |
| BH FDR-corrected | **2** |

Only the **Blind Spot effect in Both_item_task group** survives multiple comparison correction (both the paired t-test and the one-sample t-test on the difference score).

---

## D. Summary of Key Findings

1. **Blind Spot Effect ✅** — Significant in the Both_item_task group. Items presented immediately after an event boundary show reduced recognition memory (REC) compared to mid-event items (d = −0.58, p < 0.001). Trends observed in other groups.

2. **Snapshot Effect ❌** — Not significant in any group. Pre-boundary items do not show enhanced lure discrimination.

3. **Speed Bump ❌** — No significant RT differences at post-boundary positions during retrieval.

4. **RT–Memory Correlation ❌** — No reliable relationship between encoding time and memory outcomes.

5. **Lure Bin Curve** — Shows the expected monotonic decrease: more similar lures are harder to discriminate, confirming the MST is working as intended.

---

## Files Produced

| File | Location |
|---|---|
| R analysis script | [MST_Report1_Analysis.R](file:///Users/srushtipekamwar/Desktop/Semester%202/BRSM/Project%20/MST_Report1_Analysis.R) |
| Statistical results | [Report1_Results.txt](file:///Users/srushtipekamwar/Desktop/Semester%202/BRSM/Project%20/Report1_Results.txt) |
| All plots (13 PNGs) | `report1_plots/` directory |
| Extracted data CSVs | `extracted_data/` directory |

> [!NOTE]
> **For Report 2**, the significant Blind Spot effect and marginal trends suggest a factorial ANOVA (Group × Position) or mixed-effects GLM would be appropriate to formally test the interaction, controlling for group differences and random participant effects.
