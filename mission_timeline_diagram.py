#!/usr/bin/env python3
"""Generate a large timeline PNG for the Snowflake migration mission."""

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

# Factory color scheme
DARK_BG = "#0F0F23"
NODE_BG = "#16213E"
ACCENT = "#FF6B35"
ACCENT_DIM = "#E85D04"
TEXT_WHITE = "#FFFFFF"
TEXT_ACCENT = "#FF6B35"
VALIDATION_BG = "#1A1A2E"

# Extra large figure for zooming — 21600 x 12000 px at 300 dpi
fig, ax = plt.subplots(1, 1, figsize=(72, 40), facecolor=DARK_BG)
ax.set_facecolor(DARK_BG)
ax.set_xlim(0, 100)
ax.set_ylim(0, 60)
ax.axis("off")

# Phase lane Y positions (top to bottom timeline lanes)
LANES = {
    "infra": 54,
    "launch": 50,
    "phase1": 45,
    "phase2": 40,
    "phase3": 35,
    "phase35": 30,
    "phase4": 25,
    "phase5": 20,
    "phase6": 15,
    "phase7": 10,
}

# Global font scale factor — bump everything up for zoom readability
FS = 1.8

# Helper to draw a node box
def draw_box(ax, x, y, w, h, text, color=NODE_BG, border=ACCENT_DIM, linewidth=1.5, fontsize=9, textcolor=TEXT_WHITE, bold=False, radius=0.3):
    box = FancyBboxPatch((x - w/2, y - h/2), w, h,
                         boxstyle=f"round,pad=0.02,rounding_size={radius}",
                         facecolor=color, edgecolor=border, linewidth=linewidth)
    ax.add_patch(box)
    weight = "bold" if bold else "normal"
    ax.text(x, y, text, ha="center", va="center", fontsize=fontsize,
            color=textcolor, weight=weight, wrap=True,
            linespacing=1.3)
    return box

# Helper to draw an arrow
def draw_arrow(ax, x1, y1, x2, y2, color=ACCENT, lw=2, style="->"):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle=style, color=color, lw=lw,
                                connectionstyle="arc3,rad=0"))

# Helper to draw a dashed validation arrow
def draw_dashed_arrow(ax, x1, y1, x2, y2, color=ACCENT, lw=1.5):
    ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle="->", color=color, lw=lw,
                                linestyle="dashed", connectionstyle="arc3,rad=0.1"))

# =================== TITLE ===================
ax.text(50, 58.5, "Snowflake Migration Mission — End-to-End Timeline",
        ha="center", va="center", fontsize=42, color=ACCENT, weight="bold")
ax.text(50, 57.2, "AdventureWorksDW2022  →  Snowflake  |  1,060,820 rows migrated  |  40 validation assertions",
        ha="center", va="center", fontsize=22, color="gray")

# =================== PHASE 0: INFRASTRUCTURE PREP ===================
ax.text(5, LANES["infra"] + 1.8, "Phase 0: Infrastructure Prep", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

infra_nodes = [
    (12, "Install Tools\ngit, docker, uv, python"),
    (23, "Clone GitHub Repos\nETL + Dashboard"),
    (34, "Start Docker SQL Server\nAdventureWorksDW2022"),
    (45, "Connect Snowflake\nAccount: KLDJZPG-RTB48613"),
    (56, "Verify Connectivity\nSQL Server + Snowflake"),
]
for i, (x, txt) in enumerate(infra_nodes):
    draw_box(ax, x, LANES["infra"], 9.5, 2.8, txt, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, infra_nodes[i-1][0] + 4.75, LANES["infra"], x - 4.75, LANES["infra"])

# =================== LAUNCH MISSION ===================
ax.text(5, LANES["launch"] + 1.8, "Mission Launch", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

launch_nodes = [
    (14, "mission-spec.md\n+ AGENTS.md", 10, 2.8),
    (29, "Orchestrator Session\n1c4fc04f...", 12, 2.8),
    (46, "11 Features → 7 Milestones", 14, 2.8),
]
for i, (x, txt, w, h) in enumerate(launch_nodes):
    draw_box(ax, x, LANES["launch"], w, h, txt, color=DARK_BG, border=ACCENT, linewidth=2.5, fontsize=9*FS, bold=True)
    if i > 0:
        draw_arrow(ax, launch_nodes[i-1][0] + launch_nodes[i-1][2]/2, LANES["launch"],
                   x - w/2, LANES["launch"], lw=2.5)

# Connect infra to launch
draw_arrow(ax, 56 + 4.75, LANES["infra"], 14 - 5, LANES["launch"], lw=2)

# =================== PHASE 1: SOURCE DISCOVERY ===================
ax.text(5, LANES["phase1"] + 1.8, "Phase 1: Source Discovery & Assessment", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p1_nodes = [
    (12, "Parse Source Repo", 9, 2.2),
    (23, "Inventory 31/31 Tables\n48 Total Objects", 10, 2.8),
    (35, "Complexity Scoring\nSimple=23, Med=16, Complex=9", 11, 2.8),
    (48, "01-assessment-report.md", 12, 2.5),
]
for i, (x, txt, w, h) in enumerate(p1_nodes):
    col = NODE_BG if i < 3 else "#0F3460"
    bdr = ACCENT_DIM if i < 3 else ACCENT
    lw = 1.5 if i < 3 else 2.5
    draw_box(ax, x, LANES["phase1"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p1_nodes[i-1][0] + p1_nodes[i-1][2]/2, LANES["phase1"],
                   x - w/2, LANES["phase1"])

draw_arrow(ax, 46 + 7, LANES["launch"], 12 - 4.5, LANES["phase1"], lw=2)

# =================== PHASE 2: TARGET ARCHITECTURE ===================
ax.text(5, LANES["phase2"] + 1.8, "Phase 2: Target Architecture Design", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p2_nodes = [
    (14, "STAGING / DW / UTILITY\nSchemas", 10, 2.5),
    (27, "SCD Type 2 Mapping\n_valid_from, _valid_to, _is_current", 12, 2.8),
    (42, "Scheduled Notebook Design\nCRON 0 2 * * * UTC", 12, 2.8),
    (57, "02-target-architecture.md", 12, 2.5),
]
for i, (x, txt, w, h) in enumerate(p2_nodes):
    col = NODE_BG if i < 3 else "#0F3460"
    bdr = ACCENT_DIM if i < 3 else ACCENT
    lw = 1.5 if i < 3 else 2.5
    draw_box(ax, x, LANES["phase2"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p2_nodes[i-1][0] + p2_nodes[i-1][2]/2, LANES["phase2"],
                   x - w/2, LANES["phase2"])

draw_arrow(ax, 48 + 6, LANES["phase1"], 14 - 5, LANES["phase2"], lw=2)

# =================== PHASE 3: DDL GENERATION ===================
ax.text(5, LANES["phase3"] + 1.8, "Phase 3: DDL Generation & Deploy", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p3_nodes = [
    (10, "01_create_databases.sql", 9, 2.2),
    (21, "02_create_staging_tables.sql\n31 Tables", 11, 2.5),
    (33, "03_create_dw_tables.sql\n17 Dim Tables (SCD2)", 11, 2.5),
    (45, "04_create_file_formats.sql", 10, 2.2),
    (56, "05_create_stages.sql", 9, 2.2),
    (66, "Deployed to Snowflake", 10, 2.5),
]
for i, (x, txt, w, h) in enumerate(p3_nodes):
    col = NODE_BG if i < 5 else "#0F3460"
    bdr = ACCENT_DIM if i < 5 else ACCENT
    lw = 1.5 if i < 5 else 2.5
    draw_box(ax, x, LANES["phase3"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p3_nodes[i-1][0] + p3_nodes[i-1][2]/2, LANES["phase3"],
                   x - w/2, LANES["phase3"])

draw_arrow(ax, 57 + 6, LANES["phase2"], 10 - 4.5, LANES["phase3"], lw=2)

# =================== PHASE 3.5: NOTEBOOKS ===================
ax.text(5, LANES["phase35"] + 1.8, "Phase 3.5: Snowpark Notebooks", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p35_nodes = [
    (14, "notebook_scd_type2.ipynb\nMERGE Logic", 11, 2.5),
    (28, "notebook_data_quality.ipynb\nRow/Null/Dup Checks", 12, 2.5),
    (43, "notebook_load_staging.ipynb\nCOPY INTO", 11, 2.5),
    (57, "Scheduled Task SQL\n(SUSPENDED)", 11, 2.5),
]
for i, (x, txt, w, h) in enumerate(p35_nodes):
    col = NODE_BG if i < 3 else "#0F3460"
    bdr = ACCENT_DIM if i < 3 else ACCENT
    lw = 1.5 if i < 3 else 2.5
    draw_box(ax, x, LANES["phase35"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p35_nodes[i-1][0] + p35_nodes[i-1][2]/2, LANES["phase35"],
                   x - w/2, LANES["phase35"])

draw_arrow(ax, 66 + 5, LANES["phase3"], 14 - 5.5, LANES["phase35"], lw=2)

# =================== PHASE 4: DATA MIGRATION ===================
ax.text(5, LANES["phase4"] + 1.8, "Phase 4: Data Migration", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p4_nodes = [
    (13, "extract_data.py\npymssql → 31 Parquet", 11, 2.5),
    (27, "1,060,820 Total Rows\nExtracted", 10, 2.5),
    (40, "load_staging.sql\nCOPY INTO Snowflake", 11, 2.5),
    (54, "load_dw.sql\nSCD Type 2 MERGE", 10, 2.5),
    (67, "Data Deployed & Verified", 11, 2.5),
]
for i, (x, txt, w, h) in enumerate(p4_nodes):
    col = NODE_BG if i < 4 else "#0F3460"
    bdr = ACCENT_DIM if i < 4 else ACCENT
    lw = 1.5 if i < 4 else 2.5
    draw_box(ax, x, LANES["phase4"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p4_nodes[i-1][0] + p4_nodes[i-1][2]/2, LANES["phase4"],
                   x - w/2, LANES["phase4"])

draw_arrow(ax, 57 + 5.5, LANES["phase35"], 13 - 5.5, LANES["phase4"], lw=2)

# =================== PHASE 5: DASHBOARD MIGRATION ===================
ax.text(5, LANES["phase5"] + 1.8, "Phase 5: Dashboard Migration", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p5_nodes = [
    (16, "dashboard-repoint-guide.md\nPower BI → Snowflake", 14, 2.8),
    (35, "streamlit_app.py\n6 Viz + Factory AI Styling", 14, 2.8),
    (54, "dashboard-comparison-report.md\nRepoint vs Rebuild", 14, 2.8),
]
for i, (x, txt, w, h) in enumerate(p5_nodes):
    col = NODE_BG if i < 2 else "#0F3460"
    bdr = ACCENT_DIM if i < 2 else ACCENT
    lw = 1.5 if i < 2 else 2.5
    draw_box(ax, x, LANES["phase5"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p5_nodes[i-1][0] + p5_nodes[i-1][2]/2, LANES["phase5"],
                   x - w/2, LANES["phase5"])

draw_arrow(ax, 67 + 5.5, LANES["phase4"], 16 - 7, LANES["phase5"], lw=2)

# =================== PHASE 6: VALIDATION ===================
ax.text(5, LANES["phase6"] + 1.8, "Phase 6: Validation & Reconciliation", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p6_nodes = [
    (14, "Schema Validation", 9, 2.2),
    (26, "Row Count Checks", 9, 2.2),
    (38, "Checksum Validation", 9, 2.2),
    (50, "SCD Type 2 Integrity", 9, 2.2),
    (63, "05-validation-report.md", 12, 2.5),
]
for i, (x, txt, w, h) in enumerate(p6_nodes):
    col = NODE_BG if i < 4 else "#0F3460"
    bdr = ACCENT_DIM if i < 4 else ACCENT
    lw = 1.5 if i < 4 else 2.5
    draw_box(ax, x, LANES["phase6"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p6_nodes[i-1][0] + p6_nodes[i-1][2]/2, LANES["phase6"],
                   x - w/2, LANES["phase6"])

draw_arrow(ax, 54 + 7, LANES["phase5"], 14 - 4.5, LANES["phase6"], lw=2)

# =================== PHASE 7: PACKAGING ===================
ax.text(5, LANES["phase7"] + 1.8, "Phase 7: Final Packaging & Delivery", ha="left", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

p7_nodes = [
    (20, "README.md", 8, 2.2),
    (32, "deployment-guide.md", 11, 2.2),
    (46, "Makefile / deploy.sh", 11, 2.5),
]
for i, (x, txt, w, h) in enumerate(p7_nodes):
    col = NODE_BG if i < 2 else "#0F3460"
    bdr = ACCENT_DIM if i < 2 else ACCENT
    lw = 1.5 if i < 2 else 2.5
    draw_box(ax, x, LANES["phase7"], w, h, txt, color=col, border=bdr, linewidth=lw, fontsize=8.5*FS)
    if i > 0:
        draw_arrow(ax, p7_nodes[i-1][0] + p7_nodes[i-1][2]/2, LANES["phase7"],
                   x - w/2, LANES["phase7"])

draw_arrow(ax, 63 + 6, LANES["phase6"], 20 - 4, LANES["phase7"], lw=2)

# =================== VALIDATION CONTRACTS SIDEBAR ===================
# Right side validation contracts
ax.text(85, 58, "Validation Contracts", ha="center", va="center",
        fontsize=16*FS, color=ACCENT, weight="bold")
ax.text(85, 57, "40 Assertions across 8 Areas", ha="center", va="center",
        fontsize=11*FS, color="gray")

val_contracts = [
    (85, 55, "VAL-DISC-001..004\nDiscovery", 11, 2.5),
    (85, 52.5, "VAL-ARCH-001..005\nArchitecture", 11, 2.5),
    (85, 50, "VAL-DDL-001..004\nDDL", 11, 2.5),
    (85, 47.5, "VAL-NB-001..004\nNotebooks", 11, 2.5),
    (85, 45, "VAL-DATA-001..007\nData Migration", 11, 2.5),
    (85, 42.5, "VAL-DASH-001..006\nDashboard", 11, 2.5),
    (85, 40, "VAL-VAL-001..007\nValidation", 11, 2.5),
    (85, 37.5, "VAL-CROSS-001..002\nCross-Area", 11, 2.5),
]
for x, y, txt, w, h in val_contracts:
    draw_box(ax, x, y, w, h, txt, color=VALIDATION_BG, border=ACCENT, linewidth=1.5,
             fontsize=8*FS, textcolor=TEXT_ACCENT)

# =================== VALIDATOR TYPES BOX ===================
ax.text(85, 33.5, "Validator Types", ha="center", va="center",
        fontsize=14*FS, color=ACCENT, weight="bold")

validators = [
    (85, 31.5, "scrutiny-validator\ntest / typecheck / lint", 13, 2.8),
    (85, 28.5, "user-testing-validator\nassertion verification", 13, 2.8),
    (85, 25.5, "agent-browser\nStreamlit screenshot + filter test", 13, 2.8),
]
for x, y, txt, w, h in validators:
    draw_box(ax, x, y, w, h, txt, color=DARK_BG, border=ACCENT, linewidth=2, fontsize=8.5*FS, bold=True)

# =================== VALIDATION ARROWS (dashed) ===================
# Draw dashed arrows from phases to their validation contracts
# Discovery -> VAL-DISC
ax.annotate("", xy=(85 - 5.5, 55), xytext=(48, LANES["phase1"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.15"))
# Architecture -> VAL-ARCH
ax.annotate("", xy=(85 - 5.5, 52.5), xytext=(57, LANES["phase2"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# DDL -> VAL-DDL
ax.annotate("", xy=(85 - 5.5, 50), xytext=(66, LANES["phase3"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# Notebooks -> VAL-NB
ax.annotate("", xy=(85 - 5.5, 47.5), xytext=(57, LANES["phase35"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# Data -> VAL-DATA
ax.annotate("", xy=(85 - 5.5, 45), xytext=(67, LANES["phase4"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# Dashboard -> VAL-DASH + agent-browser
ax.annotate("", xy=(85 - 5.5, 42.5), xytext=(54, LANES["phase5"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# Validation -> VAL-VAL
ax.annotate("", xy=(85 - 5.5, 40), xytext=(63, LANES["phase6"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.1"))
# Packaging -> VAL-CROSS
ax.annotate("", xy=(85 - 5.5, 37.5), xytext=(46, LANES["phase7"]),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.2, linestyle="dashed", connectionstyle="arc3,rad=0.15"))

# Cross-area to validators
ax.annotate("", xy=(85, 31.5), xytext=(85, 37.5 - 1.25),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.5, linestyle="dotted"))
ax.annotate("", xy=(85, 28.5), xytext=(85, 37.5 - 1.25),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.5, linestyle="dotted"))
# Dashboard to agent-browser
ax.annotate("", xy=(85, 25.5), xytext=(85, 42.5 - 1.25),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.5, linestyle="dotted"))

# =================== LEGEND ===================
legend_x = 5
legend_y = 3.5
ax.text(legend_x, legend_y + 2.5, "Legend", ha="left", va="center",
        fontsize=12*FS, color=ACCENT, weight="bold")

# Node type legend
draw_box(ax, legend_x + 5, legend_y + 1.5, 5, 1.2, "Work Item", color=NODE_BG, border=ACCENT_DIM, fontsize=7*FS)
draw_box(ax, legend_x + 12, legend_y + 1.5, 5, 1.2, "Deliverable", color="#0F3460", border=ACCENT, linewidth=2.5, fontsize=7*FS)
draw_box(ax, legend_x + 19, legend_y + 1.5, 5, 1.2, "Validation", color=VALIDATION_BG, border=ACCENT, fontsize=7*FS, textcolor=TEXT_ACCENT)
draw_box(ax, legend_x + 26, legend_y + 1.5, 6, 1.2, "Orchestrator", color=DARK_BG, border=ACCENT, linewidth=2.5, fontsize=7*FS, bold=True)

# Arrow legend
ax.annotate("", xy=(legend_x + 50, legend_y + 1.5), xytext=(legend_x + 44, legend_y + 1.5),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=2))
ax.text(legend_x + 52, legend_y + 1.5, "Phase Flow", ha="left", va="center", fontsize=8*FS, color="gray")

ax.annotate("", xy=(legend_x + 64, legend_y + 1.5), xytext=(legend_x + 58, legend_y + 1.5),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.5, linestyle="dashed"))
ax.text(legend_x + 66, legend_y + 1.5, "Validation Link", ha="left", va="center", fontsize=8*FS, color="gray")

ax.annotate("", xy=(legend_x + 78, legend_y + 1.5), xytext=(legend_x + 72, legend_y + 1.5),
            arrowprops=dict(arrowstyle="->", color=ACCENT, lw=1.5, linestyle="dotted"))
ax.text(legend_x + 80, legend_y + 1.5, "Validator Type", ha="left", va="center", fontsize=8*FS, color="gray")

# =================== BOTTOM STATS ===================
ax.text(50, 0.8,
        "24 Sessions  •  7 Milestones  •  11 Features  •  40 Validation Assertions  •  5 Git Commits  •  1,060,820 Rows Migrated",
        ha="center", va="center", fontsize=11*FS, color="gray")

# =================== VERTICAL TIMELINE GUIDE ===================
# Add a subtle vertical timeline line on the left
for i, (name, y) in enumerate(LANES.items()):
    ax.plot([3, 3.5], [y, y], color=ACCENT, lw=2, solid_capstyle="round")
    ax.text(2.5, y, f"P{i}", ha="center", va="center", fontsize=7*FS, color=ACCENT, weight="bold")

# Save at high DPI for crisp zooming
plt.tight_layout(pad=0.5)
output_path = "/Users/dy/Documents/Sandbox/exp-snow-migration/snowflake_migration_timeline.png"
plt.savefig(output_path, dpi=300, facecolor=DARK_BG, edgecolor="none",
            bbox_inches="tight", pad_inches=0.3)
print(f"Saved to: {output_path}")
