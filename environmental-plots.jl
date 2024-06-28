env = env_daily

env.position = [s[4] for s in env.site]
env = format_date(env, "Group")
env = name_positions(env)
env = name_months(env)
env.year = parse.(Int64, env.year)
env = filter(row -> row.year > 2018, env)

# boxplots
set_default_plot_size(17cm, 15cm)
boxplot1a = Gadfly.plot(
	dropmissing(env),
	xgroup = :year,
	x = :month,
	y = :AT,
	color = :position,
	Geom.boxplot,
	Guide.xlabel("Month"),
	Guide.ylabel("Air temperature [°C]"),
	Gadfly.Scale.x_discrete(levels = month_levels),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
)

boxplot1b = Gadfly.plot(
	dropmissing(env),
	xgroup = :year,
	x = :month,
	y = :ST,
	color = :position,
	Geom.boxplot,
	Guide.xlabel("Month"),
	Guide.ylabel("Soil temperature [°C]"),
	Gadfly.Scale.x_discrete(levels = month_levels),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
)

set_default_plot_size(17cm, 30cm)
boxplot1 = vstack(boxplot1a, boxplot1b)

draw(PNG("./output-data/environmental-plots/env_boxplot_one_year.png", 17cm, 30cm), boxplot1)
draw(PDF("./output-data/environmental-plots/env_boxplot_one_year.pdf", 17cm, 30cm), boxplot1)


set_default_plot_size(40cm, 17cm)
boxplot2a = Gadfly.plot(
	dropmissing(env),
	xgroup = :year,
	x = :month,
	y = :AT,
	color = :position,
	Guide.xlabel("Month"),
	Guide.ylabel("Air temperature [°C]"),
	Gadfly.Scale.x_discrete(levels = month_levels),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
	Geom.subplot_grid(Geom.boxplot),
)

boxplot2b = Gadfly.plot(
	dropmissing(env),
	xgroup = :year,
	x = :month,
	y = :ST,
	color = :position,
	Guide.xlabel("Month"),
	Guide.ylabel("Soil temperature [°C]"),
	Gadfly.Scale.x_discrete(levels = month_levels),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
	Geom.subplot_grid(Geom.boxplot),
)

set_default_plot_size(40cm, 33cm)
boxplot2 = vstack(boxplot2a, boxplot2b)

draw(PNG("./output-data/environmental-plots/env_boxplot.png", 40cm, 33cm), boxplot2)
draw(PDF("./output-data/environmental-plots/env_boxplot.pdf", 40cm, 33cm), boxplot2)


set_default_plot_size(30cm, 17cm)
boxplot3a = Gadfly.plot(
	dropmissing(env),
	xgroup = :season,
	x = :year,
	y = :AT,
	color = :position,
	Guide.xlabel("Month"),
	Guide.ylabel("Air temperature [°C]"),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
	Geom.subplot_grid(Geom.boxplot),
)

boxplot3b = Gadfly.plot(
	dropmissing(env),
	xgroup = :season,
	x = :year,
	y = :ST,
	color = :position,
	Guide.xlabel("Month"),
	Guide.ylabel("Soil temperature [°C]"),
	Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
	Theme(background_color = "white"),
	Geom.subplot_grid(Geom.boxplot),
)

set_default_plot_size(30cm, 30cm)
boxplot3 = vstack(boxplot3a, boxplot3b)

draw(PNG("./output-data/environmental-plots/env_boxplot_seasons.png", 30cm, 30cm), boxplot3)
draw(PDF("./output-data/environmental-plots/env_boxplot_seasons.pdf", 30cm, 30cm), boxplot3)

# TODO
# handle winter (year correctly)


# lineplots
env.group = env.day .* env.position
env_mean = agg_function(env, "group")
env_mean.day = [s[1:10] for s in env_mean.Group]
date_format = Dates.DateFormat("y-m-dTH")
env_mean.date = Dates.DateTime.(env_mean.day, date_format)
env_mean.year = string.(Dates.year.(env_mean.date))
env_mean.doy = Dates.dayofyear.(env_mean.date)
env_mean.position = [s[11:length(s)] for s in env_mean.Group]

function lineplot_env_first(df, year, var, label, season_intercepts)
	input = filter(row -> row.year == year, df)
	color_bg = RGBA(0.1, 0.1, 0.6, 0.1)
	Gadfly.plot(
		input,
		x = :doy,
		y = input[:, var],
		color = :position,
		xintercept = season_intercepts,
		Guide.ylabel(label),
		Guide.xlabel(year),
		Guide.xticks(ticks = month_ticks),
		Scale.y_continuous(minvalue = -20, maxvalue = 30),
		Scale.x_continuous(minvalue = 0, maxvalue = 365, labels = x -> month_levels[round(Int, x / 30, RoundUp)]),
		Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
		Geom.line,
		Geom.vline(size = 0.2mm, style = [:solid], color = [color_bg]),
		Theme(background_color = "white",
			key_position = :none),
	)
end

function lineplot_env(df, year, var, season_intercepts)
	input = filter(row -> row.year == year, df)
	color_bg = RGBA(0.1, 0.1, 0.6, 0.1)
	Gadfly.plot(
		input,
		x = :doy,
		y = input[:, var],
		color = :position,
		xintercept = season_intercepts,
		Guide.ylabel(nothing),
		Guide.xlabel(year),
		Guide.yticks(ticks = nothing),
		Guide.xticks(ticks = month_ticks),
		Scale.y_continuous(minvalue = -20, maxvalue = 30),
		Scale.x_continuous(minvalue = 0, maxvalue = 365, labels = x -> month_levels[round(Int, x / 30, RoundUp)]),
		Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
		Geom.line,
		Geom.vline(size = 0.2mm, style = [:solid], color = [color_bg]),
		Theme(background_color = "white",
			key_position = :none),
	)
end

function lineplot_env_last(df, year, var, season_intercepts)
	input = filter(row -> row.year == year, df)
	color_bg = RGBA(0.1, 0.1, 0.6, 0.1)
	Gadfly.plot(
		input,
		x = :doy,
		y = input[:, var],
		color = :position,
		xintercept = season_intercepts,
		Guide.ylabel(nothing),
		Guide.xlabel(year),
		Guide.yticks(ticks = nothing),
		Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"),
		Theme(background_color = "white"),
		Guide.xticks(ticks = month_ticks),
		Scale.y_continuous(minvalue = -20, maxvalue = 30),
		Scale.x_continuous(minvalue = 0, maxvalue = 365, labels = x -> month_levels[round(Int, x / 30, RoundUp)]),
		Geom.line,
		Geom.vline(size = 0.2mm, style = [:solid], color = [color_bg]),
	)
end

set_default_plot_size(55cm, 20cm)
plot_complete_at = hstack(
	lineplot_env_first(env_mean, "2019", "AT", "Air temperature [°C]", season_intercepts),
	lineplot_env(env_mean, "2020", "AT", season_intercepts),
	lineplot_env(env_mean, "2021", "AT", season_intercepts),
	lineplot_env_last(env_mean, "2022", "AT", season_intercepts),
)

plot_complete_st = hstack(
	lineplot_env_first(env_mean, "2019", "ST", "Soil temperature [°C]", season_intercepts),
	lineplot_env(env_mean, "2020", "ST", season_intercepts),
	lineplot_env(env_mean, "2021", "ST", season_intercepts),
	lineplot_env_last(env_mean, "2022", "ST", season_intercepts),
)

set_default_plot_size(50cm, 30cm)
plot_complete = vstack(plot_complete_at, plot_complete_st)

draw(PNG("./output-data/environmental-plots/env_lineplot.png", 50cm, 30cm), plot_complete)
draw(PDF("./output-data/environmental-plots/env_lineplot.pdf", 50cm, 30cm), plot_complete)
