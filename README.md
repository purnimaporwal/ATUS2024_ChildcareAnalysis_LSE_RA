# ATUS 2024 — Parental Childcare Availability
**LSE RA Assessment | Part 2: Data Task**  
Purnima Porwal | June 2026

---

## Project Overview
This replication package constructs and analyses two measures of parental childcare availability using the American Time Use Survey (ATUS) 2024, grounded in Becker's (1965) household production framework:

- **M1 — Direct childcare**: hands-on care activities (ATUS tier codes 0301xx / 0401xx)
- **M2 — Child-present time**: any activity where a child was present (TUWHO_CODE)

The analysis compares M1 and M2 by parent sex (Fathers vs Mothers) and examines how much broader child-present time is relative to direct care.

The gap between M1 and M2 is the same question I have encountered in other data contexts — what a survey records as care, versus what actually constitutes being available to a child. Direct childcare codes capture hands-on investment time. Child-present time captures something closer to what a child experiences as parental presence. Neither is wrong; they measure different things, and that difference is the point of the analysis.

---

## Data
Download the five ATUS 2024 files from the BLS website:  
https://www.bls.gov/tus/data/datafiles-2024.htm

| File | Description |
|------|-------------|
| atusresp_2024.dat | Respondent file |
| atusrost_2024.dat | Household roster file |
| atusact_2024.dat | Activity file |
| atuswho_2024.dat | Who file (persons present during activity) |
| atussum_2024.dat | Summary file |

Place each file in its own subfolder exactly as downloaded:

    atusresp-2024/atusresp_2024.dat
    atusrost-2024/atusrost_2024.dat
    atusact-2024/atusact_2024.dat
    atuswho-2024/atuswho_2024.dat
    atussum-2024/atussum_2024.dat

---

## Software
R version 4.0 or above. Install required packages once by running:

    install.packages(c("readr", "xtable", "here"))

---

## How to Run
1. Open ATUS_RA_LSE.Rproj in RStudio — this sets the working directory automatically via the here package
2. Open ATUS2024_ChildcareAnalysis_Porwal.r
3. Run the script from top to bottom (Mac: Cmd+A then Cmd+Return; Windows: Ctrl+A then Ctrl+Enter)
4. All outputs are saved automatically to the output/ folder

Note: the install.packages() lines at the top only need to be run once. Comment them out after the first run.

---

## Outputs

All outputs are saved to the output/ folder when the script is run.

| File | Step | Description |
|------|------|-------------|
| broad_cat_table.tex / .csv | 3.2 | 10-category activity classification |
| becker_cat_table.tex / .csv | 3.2 | 5-category Becker (1965) classification |
| m1_codes_table.tex / .csv | 3.3 | M1 direct childcare activity codes |
| m2_codes_table.tex / .csv | 3.3 | M2 TUWHO codes used for child presence |
| m2_summary_table.tex / .csv | 3.3 | M2 episode counts by child-present status |
| diagnostics_table.tex / .csv | 3.4 | Data quality checks after merging |
| table_A_m1m2_sex.tex / .csv | 3.5 | Table A: M1 and M2 by parent sex |
| table_B_m1_m2.tex / .csv | 3.5 | Table B: M1 vs M2 overall |
| figure_m1m2_sex.png | 3.5 | Bar chart: M1 and M2 by Fathers vs Mothers |

.tex files are LaTeX source — use \input{output/filename.tex} in your LaTeX document.  
.csv files are the same tables in spreadsheet format.  
`becker_cat_table.csv`, `m1_codes_table.csv`, and `m2_codes_table.csv` also serve as activity-code crosswalks linking raw ATUS tier codes to the M1 and M2 analysis measures.

A `clean dataset/` folder is also created automatically to store `atus_merged.rds`, the cleaned activity-level dataset used from Step 3.3 onwards. `atus_merged.rds` is included in the repository. To skip Steps 3.1–3.2 and load directly from Step 3.3 onwards, run:

    atus_merged <- readRDS(here("clean dataset", "atus_merged.rds"))

---

## Helper File

| File | Description |
|------|-------------|
| ATUS2024_Codebook.tex | Variable codebook — LaTeX source |
| ATUS2024_Codebook.pdf | Variable codebook — compiled PDF; documents all selected variables, activity classifications, and methodological decisions for M1 and M2 |

---

## Workflow Summary

| Step | Description |
|------|-------------|
| 3.1 | Import 5 ATUS 2024 files; confirm ID variables and file structure |
| 3.2 | Clean variables; build activity classifications; add respondent age and sex from roster; merge child-present flag from who file; save clean dataset |
| 3.3 | Construct M1 (direct childcare) and M2 (child-present) flags; document activity codes; run consistency checks |
| 3.4 | Diagnostics: duplicate check, diary completeness, missing values, age range, activity distribution |
| 3.5 | Descriptive tables and figure; all outputs exported to output/ folder |

---

## Status

Analysis completed June 2026 as part of the LSE RA assessment task.
All outputs in the output/ folder were generated from the script and
are included here for verification. The raw ATUS files are not
included — they are too large to commit and are freely available from
the BLS link above.

---

## Reference
Becker, G. S. (1965). A Theory of the Allocation of Time. *The Economic Journal*, 75(299), 493-517.  
Bureau of Labor Statistics (2024). *American Time Use Survey User's Guide*. U.S. Department of Labor.

---

## Completion-Time Log

| Part | Approximate time |
|------|-----------------|
| Part 1 — Writing task | ~30 minutes |
| Part 2 — Data task | ~7.5–8 hours |
| **Total** | **~8–8.5 hours** |

Part 2 includes: reading documentation, downloading and importing data, cleaning and merging, debugging, using AI tools, producing outputs, writing the report, and preparing the replication package.

---
## Contact

Purnima Porwal — porwal.purnima18@gmail.com
