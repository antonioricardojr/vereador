see_themes = function(ementas_count){
    theme_count_m %>%
        streamgraph("theme", "count", "month") %>%
        sg_fill_brewer("PuOr") %>%
        sg_legend(show = TRUE, label = "gênero: ")

    p = theme_count_m %>%
        ggplot() +
        geom_area(aes(x = month, y = count, colour = ementa_type, fill = ementa_type), position = "stack")
    ggplotly(p)
}
