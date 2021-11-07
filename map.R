mymap <- leaflet() %>%
          setView(lng = -1.7, lat = 53.33, zoom = 9) %>%
          addTiles() %>%
  
          addGeoJSON(topoData, weight = 5, color = "#444444", fill = FALSE, group = "Data Boundary STEAM") %>%
  
          addLegend("bottomright", colors = "#444444", labels = "Data Boundary STEAM") %>%
  
          addLayersControl(
            overlayGroups = "Data Boundary STEAM",
            options = layersControlOptions(collapsed = FALSE))