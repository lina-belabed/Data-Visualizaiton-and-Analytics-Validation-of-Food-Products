library(shiny)
library(bslib)
library(reactable)
library(readxl)
library(dplyr)

# --- 1. SOURCE HELPER SCRIPTS ---
# This connects your R/ folder scripts to the main app
source("R/data_cleaning.R")
source("R/similarity_model.R")

# --- 2. LOAD DATA ---
# We use a tryCatch just in case the Excel files are locked or misnamed during the pitch
real_text_data <- tryCatch(load_text_data(), error = function(e) NULL)

if (is.null(real_text_data)) {
  message("Excel files not found. Loading mock data for prototype.")
  queue_data <- data.frame(
    Product = c("Ice tea peach", "Fusilli di spelta", "Pesto chips", "Endamame bonen"),
    Brand = c("Waterdrop", "La Bio Idea", "TartufLanghe", "Hak"),
    Score = c(94, 91, 72, 38)
  )
} else {
  # If the real data loads, use it (assuming it has columns like 'name', 'brand')
  # You will need to map your actual column names here
  queue_data <- real_text_data 
}

# Load ML scores (if using the real .rds file)
# scores <- load_precomputed_scores() 

# --- 3. UI ---
ui <- page_fluid(
  theme = bs_theme(version = 5, bootswatch = "flatly"),
  
  # Link your custom CSS
  tags$head(includeCSS("www/style.css")),
  
  h2("Food Dataset Validation Dashboard", class = "mb-4"),
  
  # ==========================================
  # VIEW 1: DIETITIAN QUEUE (Q1, Q2, Q3, Q6)
  # ==========================================
  card(
    card_header("View 1 · Dietitian validation queue"),
    layout_columns(
      col_widths = c(5, 7),
      
      # Left Column: Filters & Queue Table
      div(
        layout_columns(
          col_widths = c(6, 6),
          textInput("search", NULL, placeholder = "Search barcode or brand"),
          selectInput("dataset", NULL, choices = c("All datasets", "Text", "Numeric"))
        ),
        div(style="display:flex; align-items:center; gap:10px; margin-bottom:15px;",
            "Match confidence", 
            sliderInput("confidence", NULL, min = 0, max = 100, value = 85, ticks = FALSE, width="100%"),
            strong("85–100%")
        ),
        p("Queue (unvalidated, sorted by score)", class = "text-muted"),
        reactableOutput("queue_table")
      ),
      
      # Right Column: Side-by-side comparison
      div(
        p("Side-by-side with top matches · Q1", class = "text-muted"),
        tableOutput("comparison_table"),
        div(style="display:flex; gap:10px; margin-top:15px;",
            actionButton("btn_merge", "Merge and fill missing data", class="btn-primary"),
            actionButton("btn_reject", "Reject duplicate", class="btn-danger"),
            actionButton("btn_validate", "Validate as new", class="btn-success")
        )
      )
    )
  ),
  
  # ==========================================
  # VIEW 2: DEVELOPER SIMULATOR (Q4)
  # ==========================================
  card(
    card_header("View 2 · Developer similarity lab (Q4)"),
    layout_columns(
      col_widths = c(4, 8),
      
      # Left Column: Controls
      div(
        sliderInput("text_weight", "Text weight", min = 0, max = 100, value = 60),
        sliderInput("numeric_weight", "Numeric weight", min = 0, max = 100, value = 40),
        sliderInput("threshold", "Threshold", min = 0, max = 100, value = 85),
        actionButton("simulate_btn", "Simulate", class = "btn-primary w-100 mt-2")
      ),
      
      # Right Column: Before/After Mock Bars
      div(
        p("Before vs after: yield, false positives, manual workload", class = "text-muted"),
        div(style="display:grid; grid-template-columns: 120px 1fr; gap:10px; align-items:center;",
            span("Yield"), 
            div(div(class="mock-bar mock-bar-faded", style="width:55%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.3; margin-bottom:4px;"), 
                div(class="mock-bar", style="width:68%; height:10px; background:#0d6efd; border-radius:2px;")),
            
            span("False positives"), 
            div(div(class="mock-bar mock-bar-faded", style="width:30%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.3; margin-bottom:4px;"), 
                div(class="mock-bar", style="width:18%; height:10px; background:#0d6efd; border-radius:2px;")),
            
            span("Manual review"), 
            div(div(class="mock-bar mock-bar-faded", style="width:70%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.3; margin-bottom:4px;"), 
                div(class="mock-bar", style="width:52%; height:10px; background:#0d6efd; border-radius:2px;"))
        ),
        p("Faded bar = current setting, solid = simulated.", class="text-muted", style="font-size:0.75rem; margin-top:10px;")
      )
    )
  ),
  
  # ==========================================
  # VIEW 3: DATABASE MANAGER (Q5, Q7, Q8)
  # ==========================================
  card(
    card_header("View 3 · Database manager overview"),
    layout_columns(
      col_widths = c(3, 3, 3, 3),
      div(class="kpi-box", HTML("<b>152</b><span>Unvalidated (text)</span>")),
      div(class="kpi-box", HTML("<b>154</b><span>Unvalidated (numeric)</span>")),
      div(class="kpi-box", HTML("<b>— %</b><span>Merge rate, month</span>")),
      div(class="kpi-box", HTML("<b>— %</b><span>Completeness</span>"))
    ),
    br(),
    layout_columns(
      col_widths = c(6, 6),
      # Backlog by category
      div(
        p("Backlog by category, validated vs unvalidated · Q5", class = "text-muted"),
        div(style="display:grid; grid-template-columns: 100px 1fr; gap:8px; align-items:center;",
            span("No category"), div(style="width:90%; height:10px; background:#0d6efd; border-radius:2px;"),
            span("Extra"), div(style="width:12%; height:10px; background:#0d6efd; border-radius:2px;"),
            span("Dairy"), div(style="width:10%; height:10px; background:#0d6efd; border-radius:2px;"),
            span("Grains"), div(style="width:10%; height:10px; background:#0d6efd; border-radius:2px;"),
            span("Drinks"), div(style="width:10%; height:10px; background:#0d6efd; border-radius:2px;")
        )
      ),
      # Rejected suggestions
      div(
        p("Rejected suggestions per category · Q7", class = "text-muted"),
        div(style="display:grid; grid-template-columns: 100px 1fr; gap:8px; align-items:center;",
            span("Drinks"), div(style="width:60%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.6;"),
            span("Dairy"), div(style="width:40%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.6;"),
            span("Grains"), div(style="width:25%; height:10px; background:#0d6efd; border-radius:2px; opacity:0.6;")
        ),
        div(style="display:flex; gap:10px; margin-top:15px;",
            dateInput("month", NULL, value = "2026-10-01", startview = "year", width="160px"),
            actionButton("export", "Export report", class="btn-secondary")
        )
      )
    )
  )
)

# --- 4. SERVER ---
server <- function(input, output, session) {
  
  # VIEW 1: Interactive Table
  output$queue_table <- renderReactable({
    reactable(
      queue_data,
      selection = "single",
      onClick = "select",
      highlight = TRUE
    )
  })
  
  # VIEW 1: Comparison Table
  output$comparison_table <- renderTable({
    data.frame(
      Field = c("Name", "Brand", "Energy", "Sugar", "Score"),
      New = c("Ice tea peach", "Waterdrop", "—", "—", ""),
      Match1 = c("Ice tea perzik", "Waterdrop", "21", "4.8", "94%"),
      Match2 = c("Peach tea", "Lipton", "18", "3.1", "61%")
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  # VIEW 2: Simulation Reactivity (Expensive work waits for button)
  observeEvent(input$simulate_btn, {
    showNotification("Simulation run! (In production, this will update the bars)", type = "message")
    # Here is where you would update a reactiveVal with the new simulated data
  })
  
  # VIEW 3: Export
  observeEvent(input$export, {
    showNotification("Report exported successfully (Mock)", type = "message")
  })
}

shinyApp(ui, server)