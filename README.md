# Mnemonic Similarity Task (MST) Event Boundary Analysis

This repository contains an automated statistical analysis pipeline written in **R** to investigate the effects of **Event Boundaries** on human memory performance. The project processes behavioral data from a Mnemonic Similarity Task (MST) to determine how shifts in task context influence memory encoding and retrieval.

### Project Overview
The pipeline ingests raw behavioral data (Recognition scores, Lure Discrimination Indices, and Reaction Times) and performs a complete confirmatory analysis, comparing performance at **Pre-boundary**, **Post-boundary**, and **Mid-event (baseline)** positions.

### Key Hypotheses Tested
The analysis code (`MST_Report1_Analysis.R`) mathematically tests three specific memory phenomena:
*   **The "Blind Spot" Effect:** Does recognition memory (REC) drop immediately *after* an event boundary?
*   **The "Snapshot" Effect:** Is pattern separation (LDI) enhanced immediately *before* an event boundary?
*   **The "Speed Bump" Effect:** Does retrieval reaction time (RT) slow down for items encoded after a boundary?

### Features
*   **Automated Data Processing:** Imports and cleans extracted CSV data.
*   **Visualisation:** Generates publication-ready figures using `ggplot2`.
*   **Statistical Rigor:** Normality checks, Paired t-tests, and P-value corrections (Bonferroni & Benjamini-Hochberg).