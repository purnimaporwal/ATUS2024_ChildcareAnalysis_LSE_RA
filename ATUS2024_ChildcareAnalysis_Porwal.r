############ ATUS 2024 - Analysis for Parental Availability on Childcare Using R ############
############ LSE PRACTICAL TASK FOR RA POSITION ############
############ Part 2: Data Task ############
##### Purnima Porwal | June 2026 #####

### Step 3.1 — Data Access and Documentation ###

# BASICS 
# Before we start, let's make sure we have the necessary tools and files to work with the ATUS data

# check/set the working directory
getwd() # check/print the current working directory

# NOTE: if running via ATUS_RA_LSE.Rproj (recommended), this line is not needed
# as here() sets the working directory automatically. Change the path below only
# if running the script outside the project environment

setwd ("/Users/purnimaporwal/Desktop/ATUS_RA_LSE") # change this to your own path where the data is stored

# Install the packages #
install.packages("readr")  
install.packages("xtable")
install.packages("here")

# loading necessary packages
library(readr)
library(xtable)
library(here) 


# create the folders if not made manually in the folder to keep the 'clean dataset' and 'output' files
clean <- here("clean dataset")
output <- here("output")

if (!dir.exists(clean))  dir.create(clean)
if (!dir.exists(output)) dir.create(output)


### STEP 3.1 — PART 1: Import the relevant ATUS 2024 files ###

# Q1: WHICH FILES WERE USED ─ The 5 ATUS files used in this analysis are: resp, rost, act, who & sum files (maintaining the chronological order of files as provided at the BLS website)

# ATUS .dat files are same as .csv files,  so we can use read_csv() to read them directly 
# reading the 5 files into R and storing them in data frames with the same names as the files saved in the ATUS_RA_LSE folder 
# note: you can use different names if you want but I am using the same names for clarity and consistency

resp <- read_csv(here("atusresp-2024", "atusresp_2024.dat"), show_col_types = FALSE) # show_col_types=FALSE stops noisy output
rost <- read_csv(here("atusrost-2024", "atusrost_2024.dat"), show_col_types = FALSE)
act  <- read_csv(here("atusact-2024",  "atusact_2024.dat"),  show_col_types = FALSE)
who  <- read_csv(here("atuswho-2024",  "atuswho_2024.dat"),  show_col_types = FALSE) 
summ <- read_csv(here("atussum-2024",  "atussum_2024.dat"),  show_col_types = FALSE) 

# Q2: UNIT OF OBSERVATION IN EACH FILE ── Each file has a different unit of observation, which we can determine by looking at the dimensions and structure of the data frames.

# dim() gives rows * columns; 
# str() shows structure and variable types;
# head() shows first 6 rows of the data frames

dim(resp)  # each row equals one respondent
dim(rost)  # each row equals one household member per respondent
dim(act)   # each row equals one activity episode per respondent
dim(who)   # each row equals one person present during one activity
dim(summ)  # each row equals one respondent (pre-summed time totals)

# check the column/variable names in each file, excluding 'sum' file for now as it is not needed for the analysis and has same unit of observation as resp file (one row per respondent) and we can check its structure later if needed.

names(resp)[1:30]
names(rost)
names(act)[1:15] # [1:15] trims the list — showing variable names 1 to 15, not rows 1 to 15
names(who)

# understand the structure and variable types in each file

str(resp, list.len = 20)   # resp has 175 variables. So, limiting it to first 20
                        # for full list see ATUS 2024 Interview Codebook
str(rost)
str(act) 
str(who)


sapply(resp, class) # it will be too long to check all 175 variables, so we can check the codebook for variable types or use str() as done above
#maybe we can check the first 20 variables in resp for class 
sapply(resp[, 1:20], class)

# or check the specific variables we are interested in for the analysis, for instance-
sapply(resp[, c("TUFINLWGT", "TELFS", "TRCHILDNUM", "TRTCC", "TUDIARYDAY")], class)
sapply(rost, class)
sapply(act, class) # to check every column in the data frames as a vector and its type (numeric, character, factor, etc)
sapply(who, class)

head(resp) #default is 6 rows, but if you want to see more or less you can specify the number of rows in head() function, for example head(act, 12) will show the first 12 rows of the activity file
head(rost)
head(act) 
head(who)

# Q3: ID VARIABLES THAT ALLOW MERGING 

# note: ATUS 2024 user guide states: TUCASEID, TULINENO, TUACTIVITY_N are the linking variables

# TUCASEID = main respondent ID — checking it exists in all 5 files before merging
# if any file returns FALSE, the data is mismatched or from a wrong year

"TUCASEID" %in% names(resp) #checks the existence of TUCASEID in the variable names of the data frame
"TUCASEID" %in% names(rost)
"TUCASEID" %in% names(act) 
"TUCASEID" %in% names(who)

"TUCASEID" %in% names(summ)

# TULINENO = household member line number — only in 'who' and 'roster' (stated in ATUS User's Guide, Section 3 — File Structure)
# 'who' file uses it to say which household member was present during an activity episode, and 'rost' file uses it to say which household member is being described in the roster file
"TULINENO" %in% names(who)
"TULINENO" %in% names(rost)

# TUACTIVITY_N = activity sequence number — only in act and who (other files work at respondent level, so no activity number needed there)
# 'who' file uses it to link back to which specific activity the person was present during the activity episode in the 'act' file
"TUACTIVITY_N" %in% names(act)
"TUACTIVITY_N" %in% names(who)

# all checks return TRUE — merge keys confirmed present in correct files
# merging will happen in Step 3.2 later on, but we can also check the uniqueness of these keys in the data frames before merging to confirm the unit of observation and avoid any issues during merging

# resp: should have one row per respondent
nrow(resp)                        # total rows from 'resp' file
length(unique(resp$TUCASEID))     # unique IDs
# if both numbers are equal - TUCASEID is a unique identifier in 'resp' file, confirming one row per respondent

# act: one respondent has MANY activities, so TUCASEID alone is not unique
# need TUCASEID + TUACTIVITY_N together
nrow(act)
nrow(unique(act[, c("TUCASEID", "TUACTIVITY_N")]))
# if equal - the combination uniquely identifies each activity row

# rost: one respondent has multiple household members
nrow(rost)
nrow(unique(rost[, c("TUCASEID", "TULINENO")]))
# if equal - TUCASEID + TULINENO uniquely identifies each household member row

# cross-check: all three files should show the same 7,669 unique respondents
# confirms all files are from the same dataset and no file is mismatched
length(unique(resp$TUCASEID))
length(unique(rost$TUCASEID))

length(unique(act$TUCASEID))
length(unique(who$TUCASEID))

length(unique(summ$TUCASEID)) 

# UNIQUENESS CHECKS COMPLETE 

# all three checks confirmed:
#   resp  — 7,669 rows = 7,669 unique TUCASEID         (one row per respondent)
#   act   — 139,535 rows = 139,535 unique combinations  (one row per activity episode)
#   rost  — rows match unique TUCASEID + TULINENO       (one row per household member)
#   cross-check — act, resp, summ all show 7,669 unique respondents (files match)
#
# key variables are clean and ready for merging in Step 3.2
# duplicate check will be repeated after merging in Step 3.2
# to confirm the merge did not accidentally multiply any rows

### STEP 3.2 — BASIC CLEANING ###
## first, let's check all variable names from the data frames ##
names (resp)
names (rost)
names (act)
names (who)

names (summ)

# So, with this we compiled and documented the list of the variables and their details from code_book and  stata do files. 
# then we found the variables needed for the analysis 
# prepared ATUS 2024 Variable Codebook for Step 3.2 - BASIC CLEANING and Variable selection for other steps of the analysis 

# So, now we are selecting the variables we need and then merge it in the right order to create the cleaned dataset for the analysis.

### STEP 3.2 — VARIABLE SELECTION, CLEANING, AND MERGE ###

# PART 1: SELECTING ONLY VARIABLES NEEDED FROM EACH FILE
# slimming each file before merging avoids memory bloat and column conflicts

# act: episode-level base file — all other files will merge into this
# keeping all rows (blank before the comma), selecting 13 of the original 30 columns
act_clean <- act[, c("TUCASEID", "TUACTIVITY_N", "TUACTDUR24", "TUTIER1CODE", "TUTIER2CODE", "TUTIER3CODE",
                     "TRCODE", "TEWHERE", "TUCC5", "TUCC5B", "TUCC7", "TUCC8", "TRTCC_LN")]

# resp: selecting respondent-level variables needed for the analysis
resp_clean <- resp[, c("TUCASEID", "TRCHILDNUM", "TRHHCHILD", "TRYHHCHILD", "TELFS", "TRSPPRES",
                       "TUFINLWGT", "TUDIARYDAY", "TRHOLIDAY", "TRTCC", "TRTCHILD")]

# rost: selecting variables from the roster file — one row per household member
rost_clean <- rost[, c("TUCASEID", "TULINENO", "TEAGE", "TERRP", "TESEX")]

# who and summ: all variables retained (small files, no subsetting needed)
who_clean  <- who
summ_clean <- summ


# PART 2: ADDING RESPONDENT AGE AND SEX TO 'resp' cleaned file

# while checking the roster file, I noticed it includes every household member,
# including the respondent themselves — TERRP records how each person is related
# to the respondent ("how is this person related to you?")
# entries 18 and 19 both mean "self", so filtering to these gives
# exactly one row per respondent — making the merge into resp_clean one-to-one
resp_self <- rost_clean[rost_clean$TERRP %in% c(18, 19), c("TUCASEID", "TEAGE", "TESEX")]

range(resp_self$TEAGE)   # confirm age range before merging — min should be 15 or above

# add respondent's age and sex into resp_clean, matched by respondent ID
# all.x = TRUE keeps every row in resp_clean even if no match found
resp_clean <- merge(resp_clean, resp_self, by = "TUCASEID", all.x = TRUE)

# checking dimensions and variable names of each cleaned file before merging
dim(act_clean)   # rows = activity episodes, columns = variables kept
names(act_clean)
dim(resp_clean)
names(resp_clean)
dim(rost_clean)
names(rost_clean)
dim(who_clean)
names(who_clean)
dim(summ_clean)
names(summ_clean)

# PART 3: RECODE PROBLEM VALUES BEFORE MERGING

# TRCHILDNUM uses negative values (e.g., -1, -2) to mean "not collected"
# a negative value does NOT mean zero children — it means the data is missing
# recoding to NA so these are treated as missing, not as actual counts
resp_clean$TRCHILDNUM <- ifelse(resp_clean$TRCHILDNUM < 0, NA, resp_clean$TRCHILDNUM)

table(resp_clean$TRCHILDNUM, useNA = "ifany")  # distribution after recoding

# binary flag: does this respondent have at least one child in the household?
resp_clean$has_child_hh <- 0L
resp_clean$has_child_hh[!is.na(resp_clean$TRCHILDNUM) & resp_clean$TRCHILDNUM > 0] <- 1L


# cross-checking it against TRHHCHILD (1 = Yes, 2 = No) — both should tell the same story
# a mismatch here would flag a data inconsistency worth investigating
table(resp_clean$has_child_hh, resp_clean$TRHHCHILD, useNA = "ifany")
# result: 2107 with children, 5562 without — no off-diagonal mismatches, n = 7669 ✓

# checking distribution of tier codes and childcare flag before converting
table(act_clean$TUTIER1CODE, useNA = "ifany")  # broad activity category
table(act_clean$TUTIER2CODE, useNA = "ifany")  # intermediate
table(act_clean$TUTIER3CODE, useNA = "ifany")  # detailed
table(act_clean$TRTCC_LN,    useNA = "ifany")  # secondary childcare minutes per activity

# checking the variable types of the activity codes
# tier codes came in as numeric — confirming before use in comparisons

# TIER1CODE shows 1st and 2nd digits of 6-digit activity code
class(act_clean$TUTIER1CODE)   # numeric
head(act_clean$TUTIER1CODE)    # values like 1, 3, 18

# TIER2CODE shows 3rd and 4th digits of 6-digit activity code
class(act_clean$TUTIER2CODE)
head(act_clean$TUTIER2CODE)    # values like 1, 3

# TIER3CODE shows 5th and 6th digits of 6-digit activity code
class(act_clean$TUTIER3CODE)
head(act_clean$TUTIER3CODE)    # values like 1, 11

# TRTCC_LN = secondary childcare minutes per activity (-1 = not asked, 0 = none)
class(act_clean$TRTCC_LN)
head(act_clean$TRTCC_LN)      # already numeric, no conversion needed

# PART 4: CONFIRM TIER CODES ARE NUMERIC IN ACT_CLEAN
# tier codes already came in as numeric via read_csv — as.numeric() confirms this
act_clean$TUTIER1CODE <- as.numeric(act_clean$TUTIER1CODE)
act_clean$TUTIER2CODE <- as.numeric(act_clean$TUTIER2CODE)
act_clean$TUTIER3CODE <- as.numeric(act_clean$TUTIER3CODE)
# TRTCC_LN is already numeric, no conversion needed

# PART 5: ACTIVITY CLASSIFICATION

# DETAILED GROUPING: broad_cat (10 categories — own classification)
# follows ATUS tier 1 structure; used for all descriptive tables and figures
# documented in the LaTeX codebook alongside the ATUS activity lexicon
#
# extends the task's suggested 9 categories with two deliberate choices:
# (1) eating and drinking (tier 11) kept separate from personal care (tier 01)
#     — 15,787 episodes; sits closer to "necessary time" (Charmes, 2021)
#       than grooming or sleep, so collapsing them would lose that distinction
# (2) consumer and services (tiers 07–10) made explicit rather than "Other"
#     — 5,466 episodes of purposeful activity should not be obscured
act_clean$broad_cat <- NA   # tier 50 stays NA — excluded from analysis

act_clean$broad_cat[act_clean$TUTIER1CODE == 1]        <- "Personal care"
act_clean$broad_cat[act_clean$TUTIER1CODE == 2]        <- "Household activities"
act_clean$broad_cat[act_clean$TUTIER1CODE == 3]        <- "Caring for HH members"
act_clean$broad_cat[act_clean$TUTIER1CODE == 4]        <- "Caring for non-HH members"
act_clean$broad_cat[act_clean$TUTIER1CODE == 5]        <- "Work"
act_clean$broad_cat[act_clean$TUTIER1CODE == 6]        <- "Education"
act_clean$broad_cat[act_clean$TUTIER1CODE %in% 7:10]  <- "Consumer and services"
# tiers 07–10: Consumer purchases (07), Professional/personal care services (08),
#              Household services (09), Government services and civic obligations (10)
act_clean$broad_cat[act_clean$TUTIER1CODE == 11]       <- "Eating and drinking"
act_clean$broad_cat[act_clean$TUTIER1CODE %in% 12:16] <- "Leisure"
# tiers 12–16: Socializing/relaxing/leisure (12), Sports/exercise/recreation (13),
#              Religious and spiritual activities (14), Volunteer activities (15),
#              Telephone calls (16)
act_clean$broad_cat[act_clean$TUTIER1CODE == 18]       <- "Travel"
# note: tier 17 does not exist in the ATUS lexicon — sequence jumps from 16 to 18

table(act_clean$broad_cat, useNA = "ifany")
# NA = tier 50 rows — confirms data codes correctly excluded

# export broad_cat reference table to LaTeX
broad_cat_ref <- data.frame(
  Category = c("Personal care", "Household activities", "Caring for HH members",
               "Caring for non-HH members", "Work", "Education",
               "Consumer and services", "Eating and drinking", "Leisure", "Travel"),
  Code     = c("01","02","03","04","05","06","07-10","11","12-16","18"),
  Activities = c(
    "Sleep, grooming, health self-care",
    "Housework, cooking, home maintenance",
    "Childcare and adult care (within HH)",
    "Childcare and elder care (outside HH)",
    "Paid work and work-related activities",
    "Classes, homework, research",
    "Shopping; medical and financial services; household services; government obligations",
    "All meals and drinks",
    "Socializing; sports; religious activities; volunteer work; telephone calls",
    "Traveling (all modes and purposes)"
  )
)
print(xtable(broad_cat_ref,
             caption = "broad\\_cat: 10-Category Activity Classification",
             label   = "tab:broad_cat"),
      include.rownames = FALSE,
      file = here("output", "broad_cat_table.tex"))
write.csv(broad_cat_ref, here("output", "broad_cat_table.csv"), row.names = FALSE)

# PRIMARY CLASSIFICATION: becker_cat (5 categories — Becker 1965)
# Source: Becker, G. (1965). Economic Journal, 75(299), 493–517.
# childcare (tier 03) → Home production; see codebook for justification

act_clean$becker_cat <- NA   # tier 50 stays NA

act_clean$becker_cat[act_clean$TUTIER1CODE == 5]                      <- "Market work"
# tier 05: Work and work-related activities (paid work, job search)

act_clean$becker_cat[act_clean$TUTIER1CODE %in% c(2,3,4,7,8,9,10)]   <- "Home production"
# tier 02: Household activities, 03: Caring for HH members (incl. childcare),
#          04: Caring for non-HH members, 07: Consumer purchases,
#          08: Professional/personal care services, 09: Household services,
#          10: Government services and civic obligations

act_clean$becker_cat[act_clean$TUTIER1CODE %in% c(6,12,13,14,15,16)] <- "Leisure"
# tier 06: Education, 12: Socializing/relaxing/leisure,
#          13: Sports/exercise/recreation, 14: Religious/spiritual activities,
#          15: Volunteer activities, 16: Telephone calls

act_clean$becker_cat[act_clean$TUTIER1CODE %in% c(1,11)]             <- "Necessary time"
# tier 01: Personal care (sleep, grooming, health), 11: Eating and drinking

act_clean$becker_cat[act_clean$TUTIER1CODE == 18]                     <- "Travel"
# tier 18: Traveling — all modes and purposes (to work, to care, to leisure)

table(act_clean$becker_cat, useNA = "ifany")

# export becker_cat reference table to LaTeX
becker_cat_ref <- data.frame(
  Category   = c("Market work", "Home production", "Leisure",
                 "Necessary time", "Travel"),
  Tier.codes = c("05", "02-04, 07-10", "06, 12-16", "01, 11", "18"),
  Activities = c(
    "Paid work and work-related activities",
    paste("Household; caring for HH and non-HH members; shopping;",
          "professional and household services; government obligations"),
    paste("Education; socializing; sports/recreation;",
          "religious; volunteer; telephone calls"),
    "Personal care (sleep, grooming, health); eating and drinking",
    "Traveling - all modes and purposes"
  )
)
print(xtable(becker_cat_ref,
             caption = "becker\\_cat: 5-Category Classification (Becker, 1965)",
             label   = "tab:becker_cat"),
      include.rownames = FALSE,
      file = here("output", "becker_cat_table.tex"))
write.csv(becker_cat_ref, here("output", "becker_cat_table.csv"), row.names = FALSE)

# act_clean and resp_clean are now fully prepared
# only child_present is still missing — which activities had a child nearby
# the activity file does not record this; it comes from the 'who' file (Part 6)

# PART 6: CHECKING WHETHER A CHILD WAS PRESENT DURING EACH ACTIVITY
# the 'who' file records every person present during each activity episode
# TUWHO_CODE identifies their relationship to the respondent

# child relationship codes confirmed from atuswho_2024.do (official BLS Stata file):
# 22=Own HH child, 27=Foster child, 40=Own non-HH child <18,
# 52=Other non-HH family <18, 57=Other non-HH children <18
# note: codes 22/27 have no explicit age filter — assumed minor (see document)
child_codes <- c(22L, 27L, 40L, 52L, 57L)
who_clean$child_present <- who_clean$TUWHO_CODE %in% child_codes

# collapse to one row per activity
child_per_act <- aggregate(child_present ~ TUCASEID + TUACTIVITY_N, data = who_clean, FUN  = max) # FUN = max: child_present is 1 (TRUE) or 0 (FALSE)
# max of the group = 1 if ANY person in that activity was a child, 0 if none were


dim(child_per_act)
table(child_per_act$child_present, useNA = "ifany")  # 0 = no child, 1 = child present
# result: 19,150 activities with a child present (≈14% of all episodes)

# PART 7: FINAL MERGE → CLEANED ACTIVITY-LEVEL DATASET

# merging one by one to ensure we can check the merge at each step and confirm no rows are lost or duplicated during the merge process
# this is important for data integrity and to avoid silent errors that can arise from complex merges with multiple files at once

# step 1: one-to-one merge with act_clean 
# add child-present flag — match by respondent ID + activity number

atus_merged <- merge(act_clean, child_per_act, by = c("TUCASEID", "TUACTIVITY_N"), all.x = TRUE) # keeping all rows from act_clean 

# checking the merge — no rows should be lost or duplicated, and child_present column should be added
dim(atus_merged)    # rows should still be 139,535 — no rows added or lost
names(atus_merged)  # child_present column should now appear


# step 2: add respondent-level variables (age, sex, employment, children in hh, weights) - match by respondent ID only (TUCASEID) — one-to-one merge, so no risk of duplication
atus_merged <- merge(atus_merged, resp_clean, by = "TUCASEID", all.x = TRUE)

# checking the results of the merge
dim(atus_merged)    # rows should still be 139,535 — no rows added or lost
names(atus_merged)  # TESEX, TEAGE, has_child_hh etc. should now appear

# confirm no respondent went unmatched - both should return 0
sum(is.na(atus_merged$TESEX))
sum(is.na(atus_merged$TEAGE))

# confirm all the required columns are present — should return TRUE (the minimum required columns)
required_cols <- c("TUCASEID", "TUACTIVITY_N", "TUACTDUR24", "TRCODE",
                   "broad_cat", "TESEX", "TEAGE", "has_child_hh", "child_present")
all(required_cols %in% names(atus_merged))

# preview the minimum required columns 
head(atus_merged[, required_cols])

# to see the full dataset with all 28 columns — opens like a spreadsheet in RStudio
View(atus_merged)

# save the cleaned dataset in R for use in Steps 3.3 onwards
saveRDS(atus_merged, file = here("clean dataset", "atus_merged.rds"))

# Load the cleaned dataset to confirm it saves and loads correctly
atus_merged <- readRDS(here("clean dataset", "atus_merged.rds"))

# run the line below only at the start of a new R session to reload:
# atus_merged <- readRDS(here("clean dataset", "atus_merged.rds"))

# check the dimensions and variable names of the cleaned dataset
dim(atus_merged)    # should be 139,535 rows (one per activity episode)
names(atus_merged)  # should include all required columns and additional variables


### STEP 3.3 — CONSTRUCTING CHILDCARE AND CHILD-PRESENCE MEASURES ###

# Four measures of parental availability, all at the activity level:
# M1 — Direct childcare       (tier codes: 0301xx, 0401xx)
# M2 — Child present          (already built: child_present column from Part 6)
# M3 — Passive availability   (M2 minus M1: child nearby, parent not doing care)
# M4 — BLS secondary care     (TRTCC: respondent-level summary from BLS)

# Note: M3 and M4 are documented here as part of the conceptual framework
# but are not constructed in this analysis. Step 3.5 focuses on M1 and M2
# as they directly address the gendered parental availability question.

# M1: DIRECT CHILDCARE
# Domain: ATUS Lexicon groups 0301xx (HH children) and 0401xx (non-HH children).
# Within each group, Becker's (1965) investment criterion applied at tier 3:
# retain hands-on developmental/health activities; exclude logistical (030109), passive monitoring (030111 → captured by M3), and administrative (030112).
# Included TUTIER3CODEs: 01–08, 10, 99  |  Excluded: 09, 11, 12

# tier-3 codes that qualify as direct investment under Becker's criterion
becker_t3 <- c(1, 2, 3, 4, 5, 6, 7, 8, 10, 99)

# For each row in atus_merged, check all three tier conditions simultaneously:
#   TUTIER1CODE == 3  →  major category: "Caring for and helping children"
#   TUTIER2CODE == 1  →  sub-category:   "Caring for HH children" (0301xx)
#   TUTIER3CODE %in% becker_t3  →  specific activity is a Becker investment code

hh_care <- atus_merged$TUTIER1CODE == 3 & atus_merged$TUTIER2CODE == 1 &
              atus_merged$TUTIER3CODE %in% becker_t3
# A row is flagged TRUE only when all three conditions hold.

# Same logic for non-household children (TUTIER1CODE == 4 → 0401xx)
nonhh_care <- atus_merged$TUTIER1CODE == 4 & atus_merged$TUTIER2CODE == 1 &
              atus_merged$TUTIER3CODE %in% becker_t3

# M1 = TRUE if the activity is HH direct care OR non-HH direct care
atus_merged$m1_direct_care <- hh_care | nonhh_care

table(atus_merged$m1_direct_care, useNA = "ifany")
# TRUE = direct childcare (0301xx / 0401xx, tier-3 codes 01–08, 10, 99)
# FALSE = all other activities

# Document which codes are captured by M1 (task requirement).
# TUTIER2CODE is always 1 within M1; only tier 1 and tier 3 vary.

# How many M1 episodes are HH (TUTIER1=3) vs non-HH (TUTIER1=4)?
table(TUTIER1CODE = atus_merged$TUTIER1CODE[atus_merged$m1_direct_care == TRUE])

# How many M1 episodes fall under each specific tier-3 activity?
# (01=physical care, 02=reading, 03=playing, 04=arts, 05=sports,
#  06=talking, 07=retired/not in 2024, 08=organisation & planning,
#  10=attending events, 99=other)
table(TUTIER3CODE = atus_merged$TUTIER3CODE[atus_merged$m1_direct_care == TRUE])

# LaTeX table: exact codes used for M1 (for document) 
m1_direct_care <- atus_merged[atus_merged$m1_direct_care == TRUE, ]

# tier-3 activity labels (used to name rows in the output table)
m1_direct_care_labels <- c(
  "1"  = "Physical care (bathing, feeding, dressing)",
  "2"  = "Reading to / with children",
  "3"  = "Playing with children (non-sports)",
  "4"  = "Arts and crafts with children",
  "5"  = "Playing sports / outdoor activity",
  "6"  = "Talking with / listening to children",
  # note: tier-3 code 7 (t030107) was retired in an earlier ATUS wave
  # and does not appear in 2024 data — included in becker_t3 as a harmless
  # catch-all; never matched
  "7"  = "Organisation and planning (retired code — not present in 2024)",
  "8"  = "Organisation and planning for household children",
  "10" = "Attending household children's events",
  "99" = "Other care for children"
)

# build the 6-digit code and activity label for each row
m1_direct_care$Code     <- paste0(
  ifelse(m1_direct_care$TUTIER1CODE == 3, "0301", "0401"),
  sprintf("%02d", m1_direct_care$TUTIER3CODE)
)
m1_direct_care$Activity <- unname(
  m1_direct_care_labels[as.character(m1_direct_care$TUTIER3CODE)]
)

# count episodes per 6-digit code
m1_direct_care_table <- aggregate(TUTIER3CODE ~ Code + Activity,
                                  data = m1_direct_care, FUN = length)
names(m1_direct_care_table)[3] <- "N"
m1_direct_care_table <- m1_direct_care_table[order(m1_direct_care_table$Code), ]

print(m1_direct_care_table)   # verify in console before exporting

# export as LaTeX (copy output into document)
print(
  xtable(m1_direct_care_table,
         caption = "Activity codes classified as M1 direct childcare",
         label   = "tab:m1_codes"),
  include.rownames = FALSE,
  booktabs         = TRUE,
  file             = here("output", "m1_codes_table.tex")
)
write.csv(m1_direct_care_table, here("output", "m1_codes_table.csv"), row.names = FALSE)
# output/m1_codes_table.tex is now saved — paste \input{output/m1_codes_table.tex}
# into your LaTeX document where you want the table to appear

# M2: CHILD PRESENT TIME
# Broader Becker "accessible" time: any episode where at least one child was
# present, regardless of the respondent's primary activity.
# Built in Part 6 using TUWHO_CODE (BLS relationship codes from the who file):
#   22 = Own HH child          27 = Foster child
#   40 = Own non-HH child <18  52 = Other non-HH family member <18
#   57 = Other non-HH child <18
# Aggregated to activity level; already in atus_merged — no re-merge needed.
# Chosen over TRTCHILD (respondent-level) to keep the measure activity-specific.
# Covers non-HH children via codes 40/52/57 (see document for full discussion).

atus_merged$m2_child_present <- atus_merged$child_present

table(atus_merged$m2_child_present, useNA = "ifany")
# TRUE  = at least one child present during the activity episode
# FALSE = no child present

# Consistency check: every M1 activity must also have a child present (M2).
# Any M1 = TRUE / M2 = FALSE case signals an issue in the who-file merge.
table(M1_direct_care   = atus_merged$m1_direct_care,
      M2_child_present = atus_merged$m2_child_present,
      useNA = "ifany")

# LaTeX tables: M2 documentation (for document) 

# Table 1: TUWHO codes used + how many who-file records each code has.
# We use who_clean (not atus_merged) because the individual TUWHO codes were
# collapsed into a single TRUE/FALSE (child_present) in Part 6 — atus_merged
# no longer holds per-code information.
child_counts <- table(
  who_clean$TUWHO_CODE[who_clean$TUWHO_CODE %in% c(22, 27, 40, 52, 57)]
)

m2_codes_table <- data.frame(
  TUWHO_Code  = c(22, 27, 40, 52, 57),
  Description = c("Own HH child",
                  "Foster child",
                  "Own non-HH child (under 18)",
                  "Other non-HH family member (under 18)",
                  "Other non-HH child (under 18)"),
  N = as.integer(child_counts[as.character(c(22, 27, 40, 52, 57))])
)
m2_codes_table$N[is.na(m2_codes_table$N)] <- 0L

print(m2_codes_table)
print(
  xtable(m2_codes_table,
         caption = "TUWHO codes used to identify child presence (M2)",
         label   = "tab:m2_codes"),
  include.rownames = FALSE,
  booktabs         = TRUE,
  file             = here("output", "m2_codes_table.tex")
)
write.csv(m2_codes_table, here("output", "m2_codes_table.csv"), row.names = FALSE)

# Table 2: episode counts — how many activities have a child present
m2_summary <- as.data.frame(table(Child_Present = atus_merged$m2_child_present))
names(m2_summary)[2] <- "N"
print(m2_summary)
print(
  xtable(m2_summary,
         caption = "M2: Activity episodes by child-present status",
         label   = "tab:m2_summary"),
  include.rownames = FALSE,
  booktabs         = TRUE,
  file             = here("output", "m2_summary_table.tex")
)
write.csv(m2_summary, here("output", "m2_summary_table.csv"), row.names = FALSE)

### STEP 3.4 — DIAGNOSTICS ###

# Number of respondents 
# atus_merged dataset has one row per activity and unique TUCASEID for people
n_respondents <- length(unique(atus_merged$TUCASEID))
n_respondents  # unique respondents

# Number of activity records
# each row in atus_merged is one activity episode — nrow() gives the total count
n_activities  <- nrow(atus_merged)
n_activities   # total activity episodes

# confirm no rows were duplicated during the merge
nrow(atus_merged) - nrow(unique(atus_merged[, c("TUCASEID", "TUACTIVITY_N")]))
# should be 0

# Average number of activities per respondent
acts_per_resp <- table(atus_merged$TUCASEID)   # activities count per person
mean(acts_per_resp)                            # average across respondents

# Total diary minutes per respondent (TUACTDUR24 sums to 1,440 if complete)
total_diary_mins <- tapply(atus_merged$TUACTDUR24, atus_merged$TUCASEID, sum)

# minimum, maximum, and average total diary minutes per respondent
min(total_diary_mins)    # minimum total diary minutes
max(total_diary_mins)    # maximum total diary minutes
mean(total_diary_mins)   # average total diary minutes
# min = max = mean = 1,440 — all respondents have complete diaries (no partial records)
# confirms the merge did not drop or duplicate any activity episodes

# Share of respondents with exactly 1,440 diary minutes
# a complete ATUS diary covers 24 hours = 24 × 60 = 1,440 minutes
mean(total_diary_mins == 1440) * 100

# Share of activities matched to respondent-level information
# TUFINLWGT (survey weight) is present for every matched respondent
mean(!is.na(atus_merged$TUFINLWGT)) * 100

# Share of activities matched to respondent age and sex
# TEAGE and TESEX come from the roster self-merge in Part 2 of Step 3.2
mean(!is.na(atus_merged$TEAGE) & !is.na(atus_merged$TESEX)) * 100

# Share of activities matched to Who-file information
# child_present is NA for activity episodes not found in the who file
mean(!is.na(atus_merged$child_present)) * 100

# age range check — ATUS respondents must be 15 or older
range(atus_merged$TEAGE)   # min should be 15 or above

# cross-check: same respondent count in merged dataset vs original act file
length(unique(act$TUCASEID))           # unique respondents in original act file
length(unique(atus_merged$TUCASEID))   # unique respondents after merge — should match

# missing values in key variables — all should return 0
sum(is.na(atus_merged$TUACTDUR24))   # activity duration
sum(is.na(atus_merged$TELFS))        # employment status
sum(is.na(atus_merged$TUFINLWGT))    # survey weight
sum(is.na(atus_merged$TRCHILDNUM))   # NA here = recoded from negative (expected)

# distribution of activities per respondent
min(acts_per_resp)      # fewest activities recorded by one respondent
max(acts_per_resp)      # most activities recorded by one respondent
median(acts_per_resp)   # median activities per respondent

# summary of activity duration (TUACTDUR24) in minutes
mean(atus_merged$TUACTDUR24)     # average duration per activity episode
median(atus_merged$TUACTDUR24)   # median duration per activity episode

# here, the mean is more than double the median, which tells you most activities are short (eating, personal care, commuting) 
# but a few very long ones drag the average up significantly.
range(atus_merged$TUACTDUR24)    # min and max duration

# Building diagnostics table 

diagnos_table <- data.frame(
  Diagnostic = c(
    "Number of respondents",
    "Number of activity records",
    "Average activities per respondent",
    "Min diary minutes per respondent",
    "Max diary minutes per respondent",
    "Mean diary minutes per respondent",
    "Share with exactly 1,440 diary minutes (%)",
    "Share matched to respondent-level info (%)",
    "Share matched to respondent age and sex (%)",
    "Share matched to Who-file information (%)",
    "Min respondent age",
    "Max respondent age"
  ),
# counts and min/max are whole numbers; averages and shares rounded to 1 decimal
 
Value = c(
    n_respondents,
    n_activities,
    round(mean(acts_per_resp), 1),
    min(total_diary_mins),
    max(total_diary_mins),
    round(mean(total_diary_mins), 1),
    round(mean(total_diary_mins == 1440) * 100, 1),
    round(mean(!is.na(atus_merged$TUFINLWGT)) * 100, 1),
    round(mean(!is.na(atus_merged$TEAGE) &
               !is.na(atus_merged$TESEX)) * 100, 1),
    round(mean(!is.na(atus_merged$child_present)) * 100, 1),
    min(atus_merged$TEAGE),
    max(atus_merged$TEAGE)
  )
)

print(diagnos_table)

# export to LaTeX

print(
  xtable(diagnos_table,
         caption = "Data diagnostics after merging",
         label   = "tab:diagnostics"),
  include.rownames = FALSE,
  booktabs         = TRUE,
  file             = here("output", "diagnostics_table.tex")
)
write.csv(diagnos_table, here("output", "diagnostics_table.csv"), row.names = FALSE)

### STEP 3.5 — DESCRIPTIVE ANALYSIS ###

# task brief asks for one or two simple tables (examples 2-4 listed); memo focuses on
# gendered parental time availability and M1 vs M2 gap — two tables chosen accordingly:
# Table A covers brief examples 2 and 3: M1 and M2 by parent sex (Fathers vs Mothers)
# Table B covers brief example 4: comparison of direct childcare (M1) vs child-present time (M2)
# mean and median both reported — activity duration is right-skewed (mean 79 mins, median 30 mins)

# PARENT DEFINITION ────────────────────────────────────────────────────────────
# has_child_hh == 1 means TRCHILDNUM > 0: at least one own child under 18 in the household
# "own" in ATUS/CPS covers biological, adopted, and step-children only — not grandchildren, nieces/nephews, or other household members' children
# this is the standard BLS/ATUS definition used in published research (ATUS Users Guide 2024)

# DIAGNOSTIC: confirm has_child_hh and roster agree on who is a parent ─────────
# step 1 — find which TERRP code corresponds to household members under age 18
table(rost_clean$TERRP[rost_clean$TEAGE < 18], useNA = "ifany") # looking at relationship codes for household members who are children 

# step 2 — count each TERRP code among under-18 members, pick the most common one
terrp_counts <- table(rost_clean$TERRP[rost_clean$TEAGE < 18])
terrp_counts                                                     # see all counts
child_terrp  <- as.integer(names(which.max(terrp_counts)))
child_terrp                                                      # prints 22 — own child code confirmed

parent_ids   <- unique(rost_clean$TUCASEID[rost_clean$TERRP == child_terrp])

# step 3 — cross-check: what share of has_child_hh==1 respondents also appear in roster?
parent_resp <- unique(atus_merged$TUCASEID[atus_merged$has_child_hh == 1])
round(mean(parent_resp %in% parent_ids) * 100, 1)
# ~85% match is expected — gap is step-children (TERRP == 40), who TRCHILDNUM counts but TERRP 22 excludes
# confirms has_child_hh is slightly broader (more inclusive) — consistent with BLS definition
# analysis below uses has_child_hh (TRCHILDNUM-based) as it is the primary BLS variable

# TESEX: 1 = Male (Fathers), 2 = Female (Mothers)

# TABLE A: M1 and M2 minutes per day — Fathers vs Mothers (parents only) ───────
# two-step approach: step 1 = sum minutes per person; step 2 = average across people by sex
# step 1 — total M1 minutes per parent (one row per parent after summing all their M1 episodes)
m1_daily_mins <- aggregate(TUACTDUR24 ~ TUCASEID + TESEX,
                       data = atus_merged[atus_merged$m1_direct_care == TRUE &
                                          atus_merged$has_child_hh == 1, ], FUN = sum)

# step 1 — total M2 minutes per parent (same logic for child-present time)
m2_daily_mins <- aggregate(TUACTDUR24 ~ TUCASEID + TESEX,
                       data = atus_merged[atus_merged$m2_child_present == TRUE &
                                          atus_merged$has_child_hh == 1, ], FUN = sum)

# step 2 — average across all parents by sex (tapply groups by TESEX: 1=Fathers, 2=Mothers)
table_A <- data.frame(
  Parent    = c("Fathers", "Mothers"),
  M1_Mean   = round(tapply(m1_daily_mins$TUACTDUR24, m1_daily_mins$TESEX, mean), 1),
  M1_Median = round(tapply(m1_daily_mins$TUACTDUR24, m1_daily_mins$TESEX, median), 1),
  M2_Mean   = round(tapply(m2_daily_mins$TUACTDUR24, m2_daily_mins$TESEX, mean), 1),
  M2_Median = round(tapply(m2_daily_mins$TUACTDUR24, m2_daily_mins$TESEX, median), 1)
)

print(table_A)
# note: averages are conditional on participation — only parents who did at least one M1/M2
# activities on the diary day are included; parents with zero minutes that day are excluded
# mothers spend more time than fathers in both M1 and M2; M2 >> M1 for both (roughly 3x)
# mean > median in all columns — confirms right-skewed distribution (some parents do very long hours)

print(xtable(table_A,
             caption = "M1 direct childcare and M2 child-present minutes per day: Fathers vs Mothers",
             label   = "tab:desc_m1m2_sex"),
      include.rownames = FALSE, booktabs = TRUE,
      file = here("output", "table_A_m1m2_sex.tex"))
write.csv(table_A, here("output", "table_A_m1m2_sex.csv"), row.names = FALSE)

# TABLE B: M1 vs M2 overall (parents only) 
# shows the gap between narrow (M1) and broad (M2) childcare measures for parents
# two-step approach: step 1 = sum minutes per person; step 2 = average across all parents
# step 1 — total M1 minutes per parent (no sex split — overall comparison only)
m1_overall_mins <- aggregate(TUACTDUR24 ~ TUCASEID,
                              data = atus_merged[atus_merged$m1_direct_care == TRUE & atus_merged$has_child_hh == 1, ], FUN = sum)

# step 1 — total M2 minutes per parent
m2_overall_mins <- aggregate(TUACTDUR24 ~ TUCASEID,
                              data = atus_merged[atus_merged$m2_child_present == TRUE & atus_merged$has_child_hh == 1, ], FUN = sum)

# step 2 — mean and median across all parents
table_B <- data.frame(
  Measure = c("M1: Direct childcare", "M2: Child-present time"),
  Mean    = round(c(mean(m1_overall_mins$TUACTDUR24), mean(m2_overall_mins$TUACTDUR24)), 1),
  Median  = round(c(median(m1_overall_mins$TUACTDUR24), median(m2_overall_mins$TUACTDUR24)), 1)
)

print(table_B)
# note: averages conditional on participation — same as Table A
# M2 mean (399.0) is roughly 3x M1 mean (125.5) showing that most parental time near children is passive, not direct care
# mean > median for both — right-skewed; median better represents the typical parent's day
print(xtable(table_B,
             caption = "M1 direct childcare vs M2 child-present time (parents only)",
             label   = "tab:desc_m1_m2"),
      include.rownames = FALSE, booktabs = TRUE,
      file = here("output", "table_B_m1_m2.tex"))
write.csv(table_B, here("output", "table_B_m1_m2.csv"), row.names = FALSE)

# FIGURE: M1 and M2 mean minutes per day — Fathers vs Mothers
# grouped bar chart showing Table A results visually; saved as PNG
png(here("output", "figure_m1m2_sex.png"))
barplot(rbind(table_A$M1_Mean, table_A$M2_Mean),
        beside    = TRUE,
        names.arg = c("Fathers", "Mothers"),
        ylab      = "Mean minutes per day",
        legend    = c("M1: Direct care", "M2: Child-present"),
        col       = c("steelblue", "tomato"))
dev.off()

### PART 2 COMPLETE ###
# Steps 3.1 to 3.5 are done:
#   3.1 — data accessed, files imported, ID variables confirmed
#   3.2 — basic cleaning: variables selected, tier codes confirmed numeric,
#          respondent age/sex added from roster, M1 and M2 flags constructed,
#          child_present flag merged from Who file, clean dataset saved
#   3.3 — measures built: M1 (direct childcare, TUTIER1/2/3 codes),
#          M2 (child-present time, TUWHO_CODE), activity table documented
#   3.4 — diagnostics: duplicate check, diary completeness, missing values,
#          age range, distribution of activities per respondent
#   3.5 — descriptive analysis: Table A (M1 and M2 by parent sex),
#          Table B (M1 vs M2 overall), bar chart figure — all saved to output/
# interpretation (Step 3.6) written in the LaTeX document

# replication package: README.md + ATUS2024_ChildcareAnalysis_Porwal.r + output/ folder

