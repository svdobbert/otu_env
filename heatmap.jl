using (StatsBase)
using CategoricalArrays

function create_heatmap(df, year, bins, env_var, label)
	heatmap_input = filter(row -> row.year == year, df)[:, 1:5]
	heatmap_input.category = string.(cut(heatmap_input[:, env_var], bins, labels = 1:bins))

	heatmap_input.group = heatmap_input.variable .* "_" .* heatmap_input.category
	heatmap_input_agg = agg_function(heatmap_input, "group")
	heatmap_input_agg.class = getindex.(split.(heatmap_input_agg.Group, "_"), 1)
	heatmap_input_agg.category = getindex.(split.(heatmap_input_agg.Group, "_"), 2)

	heatmap_input_agg.category = parse.(Int, heatmap_input_agg.category)
	standard = fit(UnitRangeTransform, heatmap_input_agg.value; dims = 1)
	heatmap_input_agg.value_std = StatsBase.transform(standard, heatmap_input_agg.value)
    
    set_default_plot_size(15cm, 20cm)
	cpalette(p) = get(ColorSchemes.BuPu_3, p)
	Gadfly.plot(
		heatmap_input_agg,
		x = :class,
		y = :category,
		color = :value_std,
		Coord.cartesian(ymax = bins, ymin = 1),
		Geom.rectbin,
        Guide.xlabel("class"),
        Guide.ylabel(label),
		Guide.yticks(label = false),
		Scale.color_continuous(colormap = cpalette),
		Theme(background_color = "white"),
	)
end

input = filter(row -> row.variable == "Acidobacteriae" || row.variable == "Alphaproteobacteria", reshaped_input)
create_heatmap(input, "2020", 25, "temp", "Temperature (PC1)")
create_heatmap(input, "2021", 25, "temp", "Temperature (PC1)")
create_heatmap(input, "2022", 25, "temp", "Temperature (PC1)")


# TODO
# plot for one class and months/seasons on x-Axis
