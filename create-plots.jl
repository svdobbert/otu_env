
# Plots.scatter(plot_input_df.temp, plot_input_df[:, class],
# 	group = plot_input_df.year,
# 	title = class,
# 	xlabel = "Air temperature (PC1)",
# 	ylabel = "Mean",
# 	legend = true,
# 	marker = (:circle, 8),
# 	grid = true)

#scatter plots
function reduced_scatter(at, st, var)
	reduced = DataFrame(
		"AT" => reduce_dim(at),
		"ST" => reduce_dim(st),
		"id" => names(at, findall(x -> eltype(x) != String, eachcol(at))))

	reduced.position = [s[4] for s in reduced.id]
	reduced.region = [s[1] for s in reduced.id]
	reduced.site = [s[2:3] for s in reduced.id]

	group = reduced[:, var]
	Plots.scatter(reduced.AT, reduced.ST, group = group, xlabel = "Air temperature", ylabel = "Soil temperature",
		legend = true, marker = (:circle, 8), grid = true)
end

reduced_scatter(at_date, st_date, "position")
reduced_scatter(at_monthly, st_monthly, "position")
reduced_scatter(at_seasonal, st_seasonal, "position")
reduced_scatter(at_annual, st_annual, "position")

reduced_scatter(at_daily, st_daily, "region")
reduced_scatter(at_monthly, st_monthly, "region")
reduced_scatter(at_seasonal, st_seasonal, "region")
reduced_scatter(at_annual, st_annual, "region")

reduced_scatter(at_daily, st_daily, "site")
reduced_scatter(at_monthly, st_monthly, "site")
reduced_scatter(at_seasonal, st_seasonal, "site")
reduced_scatter(at_annual, st_annual, "site")

set_default_plot_size(27cm, 20cm)
Gadfly.plot(
	plot_input_df,
	x = :temp,
	y = plot_input_df[:, class],
	color = :year,
	shape = :region,
	alpha = [0.9],
	size = [1.5mm],
	Geom.point,
	Guide.xticks(label = false),
	Guide.xlabel("Temperature (PC1)"),
	Guide.ylabel("Mean"),
	Guide.title(class),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70"),
	Theme(
		background_color = "white",
		default_color = "black",
	),
)

# 3D
PlotlyJS.plot(
	plot_input_df,
	x = :temp,
	y = :temp_pre,
	z = plot_input_df[:, class],
	color = :year,
	symbol = :region,
	kind = "scatter3d", mode = "markers+text",
	Layout(
		title = class,
	),
)

cpalette(p) = get(ColorSchemes.BuPu_3, p)
Gadfly.plot(
	plot_input_df,
	x = :AT,
	y = :ST,
	color = plot_input_df[:, class],
	shape = :region,
	alpha = [0.7],
	size = [1.5mm],
	Geom.point,
	Guide.xticks(label = false),
	Guide.yticks(label = false),
	Guide.xlabel("Air temperature (PC1)"),
	Guide.ylabel("Soil temperature (PC1)"),
	Guide.title(class),
	Scale.color_continuous(colormap = cpalette),
	Theme(
		background_color = "white",
		default_color = "black",
	),
)

# boxplots
function boxplot_threshold(df, y, threshold, label)
	df = filter(row -> row.value > threshold, df)

	set_default_plot_size(90cm, 20cm)
	Gadfly.plot(
		df,
		x = :variable,
		y = df[:, y],
		color = :year,
		Geom.boxplot,
		Guide.yticks(label = false),
		Guide.xlabel("Class"),
		Guide.ylabel(label),
		Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70"),
		Theme(
			background_color = "white",
			default_color = "black",
		),
	)
end

threshold = 5
boxplot_threshold(reshaped_input, "temp", threshold, "Temperature (PC1)")
boxplot_threshold(reshaped_input, "AT", threshold, "Air temperature (PC1)")
boxplot_threshold(reshaped_input, "ST", threshold, "Soil temperature (PC1)")
boxplot_threshold(reshaped_input, "temp_pre", threshold, "Temperature (pre year) (PC1)")
boxplot_threshold(reshaped_input, "AT_pre", threshold, "Air temperature (pre year) (PC1)")
boxplot_threshold(reshaped_input, "ST_pre", threshold, "Soil temperature (pre year) (PC1)")

boxplot_threshold(reshaped_input, "spring", threshold, "Temperature (spring) (PC1)")
boxplot_threshold(reshaped_input, "summer", threshold, "Temperature (summer) (PC1)")
boxplot_threshold(reshaped_input, "winter", threshold, "Temperature (winter) (PC1)")

