# Pacotes -----------------------------------------------------------------

library(shiny)
library(bs4Dash)
library(thematic)
library(readr)
library(data.table)
library(tidyr)
library(dplyr)
library(echarts4r)
library(leaflet)
library(prophet)
library(shinyWidgets)
library(formattable)
library(dygraphs)
library(readxl)
library(waiter)

# User Interface ----------------------------------------------------------

ui = bs4DashPage(
  
  # Opções
  fullscreen = TRUE,
  help = FALSE,
  dark = FALSE,
  scrollToTop = FALSE,
  
  # Navbar (Menu Superior) 
  header = bs4DashNavbar(
    disable = FALSE, 
    fixed = TRUE,
    border = TRUE,
    compact = FALSE,
    skin = "light",
    status = "white",
    sidebarIcon = shiny::icon("bars"),
    controlbarIcon = shiny::icon("th"),
    # Cabeçalho do Dashboard
    title = dashboardBrand(
      title = "©MPPallante",
      color = "primary",
      image = "https://lh3.googleusercontent.com/ogw/ADGmqu_hZZbh1ioBDSRRb8W85PrmMbB07wcshDOJcM8V9g=s83-c-mo", 
      href = "https://mppallante.wixsite.com/mppallante",
      opacity = 0.8
    ),
    # Caixa de Mensagens
    rightUi = tagList(
      dropdownMenu(
        headerText = "Você tem 1 notificação",
        badgeStatus = "danger",
        type = "messages",
        icon = shiny::icon("bell"),
        messageItem(
          inputId = "triggerAction1",
          from = HTML("<strong>Desenvolvedor</strong>"),
          message = HTML("Atualização realizada!
                         <br>Layout:2.0"),
          image = "https://lh3.googleusercontent.com/ogw/ADGmqu_hZZbh1ioBDSRRb8W85PrmMbB07wcshDOJcM8V9g=s83-c-mo",
          time = "Hoje",
          color = "navy",
          icon = shiny::icon("code")
        )
      )
    )
  ),
  
  # Sidebar (Menu Lateral)
  sidebar = bs4DashSidebar(
    # Opções
    id = "sidebar",
    disable = FALSE,
    fixed = TRUE,
    collapsed = FALSE,
    minified = TRUE,
    expandOnHover = TRUE,
    width = NULL,
    elevation = 4,
    skin = "light",
    status = "primary",
    customArea = NULL,
    # Segundo Titulo
    sidebarUserPanel(
      name = HTML("<strong>COVID-19 BRASIL</strong>"),
      image = NULL
    ),
    # Menu
    sidebarMenu(
      sidebarHeader("Análise Descritiva"),
      # Página 1
      menuItem(
        selected = TRUE,
        text = "Coronavírus no Brasil",
        tabName = "descritive",
        icon = shiny::icon("chart-pie")
      ),
      sidebarHeader("Análise Estatística"),
      # Página 2
      menuItem(
        text = "Projeção de Contágios",
        tabName = "statistic",
        icon = shiny::icon("chart-line")
      ),
      # Página 3
      menuItem(
        text = "Riscos de Disseminação",
        tabName = "knn",
        icon = shiny::icon("project-diagram")
      ),
      sidebarHeader("Informações"),
      # Página 4
      menuItem(
        text = "Aplicação",
        tabName = "about",
        icon = shiny::icon("info")
      )
    )
  ),
  
  # Controlbar (Menu de Controles)
  # controlbar = dashboardControlbar(
  #   # Opções
  #   id = "controlbar",
  #   disable = FALSE,
  #   pinned = FALSE,
  #   collapsed = TRUE,
  #   overlay = TRUE,
  #   width = 250,
  #   skin = "light",
  #   controlbarMenu(
  #     # Opções
  #     id = "controlbarMenu",
  #     type = "pills",
  #     selected = "Controles",
  #     #  Menu de Controles
  #     controlbarItem(
  #       title = "Controles"
  #       
  #     ),
  #     # Menu de temas
  #     controlbarItem(
  #       title = "Temas",
  #       skinSelector()
  #     )
  #   )
  # ),
  
  # Main Body (Corpo Principal)
  body = bs4DashBody(
    bs4TabItems(
      # Página 1 - Coronavírus no Brasil
      bs4TabItem(
        use_waiter(),
        tabName = "descritive",
        # Indicadores de Casos Confirmados, Recuperados e Mortes
        bs4Card(
          title = "Indicadores de Casos Confirmados, Recuperados e Mortes", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = NULL,
          status = "primary",
          fluidRow(
            bs4InfoBoxOutput("ConfirmedBR", width = 6),
            bs4InfoBoxOutput("recupBR", width = 6),
            bs4InfoBoxOutput("DeathBR", width = 6),
            bs4InfoBoxOutput("indBR", width = 6)
          )
        ),
        # Contágio nos Estados (Casos Confirmados)
        bs4Card(
          title = "Contágio nos Estados (Casos Confirmados)", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = 600,
          status = "primary",
          leafletOutput('GeoBrasil', width = "100%", height = "100%")
        ),
        # Casos Confirmados versus Mortes por Estado
        bs4Card(
          title = "Casos Confirmados versus Mortes por Estado", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = 600,
          status = "primary",
          echarts4rOutput('NumEstado', width = "100%", height = "100%")
        ),
        # Evolutivo de Contágio por Estado
        bs4Card(
          title = "Evolutivo de Contágio por Estado", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = 600,
          status = "primary",
          echarts4rOutput('TimeEstado', width = "100%", height = "100%")
        )
      ),
      # Página 2 - Projeção de Contágios
      bs4TabItem(
        use_waiter(),
        tabName = "statistic",
        fluidRow(
          column(
            width = 11,
            # Projeção de Contágios para os próximos 15 dias
            bs4Card(
              title = "Projeção de Contágios para os próximos 15 dias", 
              closable = FALSE,
              collapsible = FALSE,
              collapsed = FALSE,
              maximizable = TRUE,
              solidHeader = TRUE, 
              elevation = 4,
              width = 12,
              height = 350,
              status = "primary",
              dygraphOutput('ConfirmedE_BR', width = '100%', height = '100%')
            ),
            # Projeção de Mortes para os próximos 15 dias
            bs4Card(
              title = "Projeção de Mortes para os próximos 15 dias", 
              closable = FALSE,
              collapsible = FALSE,
              collapsed = FALSE,
              maximizable = TRUE,
              solidHeader = TRUE, 
              elevation = 4,
              width = 12,
              height = 350,
              status = "primary",
              dygraphOutput('DeathsE_BR', width = '100%', height = '100%')
            )
          ),
          column(
            width = 1,
            prettyRadioButtons(
              inputId = "Estados",
              label = "Localiddade:", 
              choices = c("BRASIL","SP","RJ","AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI","PR","RN","RO","RR","RS","SC","SE","TO"),
              selected = "BRASIL",
              status = "primary",
              animation = "smooth"
            )
          )
        )
      ),
      # Página 3 - Riscos de Disseminação
      bs4TabItem(
        use_waiter(),
        tabName = "knn",
        # Concentração de Casos Confirmados (Agrupamentos)
        bs4Card(
          title = "Concentração de Casos Confirmados (Agrupamentos)", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = 450,
          status = "primary",
          leafletOutput('ClusterBrasil', width = '100%', height = '100%')
        ),
        # Informações sobre os Agrupamentos
        bs4Card(
          title = "Informações sobre os Agrupamentos", 
          closable = FALSE,
          collapsible = FALSE,
          collapsed = FALSE,
          maximizable = TRUE,
          solidHeader = TRUE, 
          elevation = 4,
          width = 12,
          height = 220,
          status = "primary",
          formattableOutput('ClusterTable', width = '100%', height = '100%')
        )
      ),
      # Página 4 - Aplicação
      bs4TabItem(
        tabName = "about",
        use_waiter(),
        bs4Jumbotron(
          title = "COVID-19 BRASIL",
          lead = "Desenvolvido para análise dos casos de COVID-19 no Brasil",
          status = "primary",
          btnName = "GITHUB",
          href = "https://github.com/mppallante/COVID19-BR"
        )
      )
    )
  ),
  
  # Footer
  footer = dashboardFooter(
    fixed = FALSE,
    left = a(
      href = "https://mppallante.wixsite.com/mppallante",
      target = "_blank", "©MPPallante. Todos os direitos reservados."
    ),
    right = lubridate::year(Sys.time())
  )
  
)
