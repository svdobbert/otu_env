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
		Scale.color_continuous(colormap = custom_colormap),
		Theme(background_color = "white"),
	)
end

class = class_names[5]
set_default_plot_size(70cm, 17cm)
input = reshaped_input
# input = filter(row -> row.variable == class, reshaped_input)
create_heatmap(input, "2020", 25, "temp", "Temperature (PC1)")
create_heatmap(input, "2021", 25, "temp", "Temperature (PC1)")
create_heatmap(input, "2022", 25, "temp", "Temperature (PC1)")

function create_heatmap_months(df, env_var, label, class, position, region)
	if position != "all positions"
		df = filter(row -> row.position == position, input)
	end

	if region != "all sites"
		df = filter(row -> row.region == region, input)
	end

	df.value = replace!(df.value, missing => 0)
	heatmap_input = dropmissing(df)

	max = round(Int, maximum(heatmap_input[:, env_var]))
	min = round(Int, minimum(heatmap_input[:, env_var]))
	bins = round(Int, (max - min))
	heatmap_input = filter(row -> row.variable == class, heatmap_input)
	heatmap_input.category = string.(cut(heatmap_input[:, env_var], bins, labels = 1:bins))
	heatmap_input.group = heatmap_input.variable .* "_" .*
						  heatmap_input.category .* "_" .*
						  heatmap_input.year .* "_" .*
						  string.(heatmap_input.month)

	heatmap_input = select!(heatmap_input, [:group, :value, :AT, :ST])

	heatmap_input_agg = agg_function(heatmap_input, "group")
	heatmap_input_agg.class = getindex.(split.(heatmap_input_agg.Group, "_"), 1)
	heatmap_input_agg.category = getindex.(split.(heatmap_input_agg.Group, "_"), 2)
	heatmap_input_agg.category = parse.(Int, heatmap_input_agg.category)
	heatmap_input_agg.year = getindex.(split.(heatmap_input_agg.Group, "_"), 3)
	heatmap_input_agg.month = getindex.(split.(heatmap_input_agg.Group, "_"), 4)
	heatmap_input_agg = name_months(heatmap_input_agg)

	standard = fit(UnitRangeTransform, heatmap_input_agg.value; dims = 1)
	heatmap_input_agg.value_std = StatsBase.transform(standard, heatmap_input_agg.value)

	heatmap_input_agg.y_labels = round.(Int, heatmap_input_agg[:, env_var])

	set_default_plot_size(25cm, 15cm)
	Gadfly.plot(
		heatmap_input_agg,
		xgroup = :year,
		x = :month,
		y = :y_labels,
		color = :value,
		#Coord.cartesian(ymax = bins, ymin = 1),
		#Geom.rectbin,
		Guide.title(class .* " - " .* position .* " - " .* region),
		Guide.ylabel(label),
		Guide.xlabel(""),
		Scale.color_continuous(colormap = custom_colormap2),
		Theme(background_color = "white"),
		Geom.subplot_grid(Geom.rectbin),
		Scale.y_continuous(minvalue = -12, maxvalue = 17),
	)
end
test = create_heatmap_months(input, "AT", "Air temperature", class, "all positions", "all sites")

function save_heatmap_plots(input, class)
	if !isdir("./output-data/heatmaps/" * class * "/")
		mkdir("./output-data/heatmaps/" * class * "/")
	end

	plot_all = vstack(
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "all positions", "all sites"),
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "all positions", "all sites"),
	)

	draw(PNG("./output-data/heatmaps/" * class * "/heatmap_by_month_all_" * class * ".png", 25cm, 30cm), plot_all)
	draw(PDF("./output-data/heatmaps/" * class * "/heatmap_by_month_all_" * class * ".pdf", 25cm, 30cm), plot_all)


	plot_by_position_at = vstack(
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "ridge", "all sites"),
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "slope", "all sites"),
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "depression", "all sites"),
	)

	draw(PNG("./output-data/heatmaps/" * class * "/heatmap_by_month_position_at_" * class * ".png", 25cm, 40cm), plot_by_position_at)
	draw(PDF("./output-data/heatmaps/" * class * "/heatmap_by_month_position_at_" * class * ".pdf", 25cm, 40cm), plot_by_position_at)


	plot_by_position_st = vstack(
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "ridge", "all sites"),
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "slope", "all sites"),
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "depression", "all sites"),
	)

	draw(PNG("./output-data/heatmaps/" * class * "/heatmap_by_month_position_st_" * class * ".png", 25cm, 40cm), plot_by_position_st)
	draw(PDF("./output-data/heatmaps/" * class * "/heatmap_by_month_position_st_" * class * ".pdf", 25cm, 40cm), plot_by_position_st)


	plot_by_region_at = vstack(
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "all positions", "Geiranger/Møre og Romsdal region"),
		create_heatmap_months(input, "AT", "Air temperature [°C]", class, "all positions", "Vågå/Innlandet region"),
	)

	draw(PNG("./output-data/heatmaps/" * class * "/heatmap_by_month_region_at_" * class * ".png", 25cm, 30cm), plot_by_region_at)
	draw(PDF("./output-data/heatmaps/" * class * "/heatmap_by_month_region_at_" * class * ".pdf", 25cm, 30cm), plot_by_region_at)


	plot_by_region_st = vstack(
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "all positions", "Geiranger/Møre og Romsdal region"),
		create_heatmap_months(input, "ST", "Soil temperature [°C]", class, "all positions", "Vågå/Innlandet region"),
	)

	draw(PNG("./output-data/heatmaps/" * class * "/heatmap_by_month_region_st_" * class * ".png", 25cm, 30cm), plot_by_region_st)
	draw(PDF("./output-data/heatmaps/" * class * "/heatmap_by_month_region_st_" * class * ".pdf", 25cm, 30cm), plot_by_region_st)
end

class = class_names[7]

input = reshaped_monthly
input.position = [s[4] for s in input.site]
input.region = [s[1] for s in input.site]
input = name_positions(input)
input = name_regions(input)

save_heatmap_plots(input, class)

# create and save plots for all classes
length(class_names)
for i in class_names
	save_heatmap_plots(input, i)
end
