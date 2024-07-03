using Dates             # provides types for working with dates
using Statistics        # basic statistics functionality.
using MultivariateStats # for multivariate statistics and data analysis
using Plots             # powerful convenience for visualization in Julia
using LinearAlgebra# common and useful linear algebra operations 
using Gadfly# a system for plotting and visualization 
using Compose# a declarative vector graphics system written in Julia
using ColorSchemes# a set of pre-defined ColorSchemes
using PlotlyJS# interface to the [plotly.js] visualization library

at_date = format_date(at, "date time")
st_date = format_date(st, "date time")

# daily
at_daily = agg_function(at_date, "day")
st_daily = agg_function(st_date, "day")

env_daily_bind = bind_env(at_daily, st_daily)
env_daily = reshape(at_daily, st_daily)

# monthly
at_monthly = agg_function(at_date, "month")
st_monthly = agg_function(st_date, "month")

env_monthly_bind = bind_env(at_monthly, st_monthly)
env_monthly = reshape(at_monthly, st_monthly)

# monthly by year
at_date.monthYear = at_date.month .* "_" .* at_date.year
at_monthYear = agg_function(at_date, "monthYear")
st_date.monthYear = st_date.month .* "_" .* st_date.year
st_monthYear = agg_function(st_date, "monthYear")

env_monthYear_bind = bind_env(at_monthYear, st_monthYear)
env_monthYear = reshape(at_monthYear, st_monthYear)
env_monthYear.month = getindex.(split.(env_monthYear.Group, "_"), 1)
env_monthYear.year = getindex.(split.(env_monthYear.Group, "_"), 2)

# seasonal
at_seasonal = agg_function(at_date, "season")
st_seasonal = agg_function(st_date, "season")

env_seasonal_bind = bind_env(at_seasonal, st_seasonal)
env_seasonal = reshape(at_seasonal, st_seasonal)

# annual
at_annual = agg_function(at_date, "year")
st_annual = agg_function(st_date, "year")

env_annual_bind = bind_env(at_annual, st_annual)
env_annual = reshape(at_annual, st_annual)


at_reduced = reduce_dim(at_daily)
st_reduced = reduce_dim(st_daily)

split_df = transpose_df(class_mean)

ids = names(at, findall(x -> eltype(x) != String, eachcol(at)))

function create_env(at_input, st_input, year, ids)
	preyear = string(parse(Int, year) - 1)
	if preyear in at_input.year
		preyear = preyear
	else
		preyear = year
	end

	at = filter(row -> row.year == year, at_input)
	st = filter(row -> row.year == year, st_input)

	at_pre = filter(row -> row.year == preyear, at_input)
	st_pre = filter(row -> row.year == preyear, at_input)

	env_reduced = DataFrame(
		"id" => ids,
		"temp" => reduce_dim([at; st]),
		"temp_pre" => reduce_dim([at_pre; st_pre]),
		"AT" => reduce_dim(at),
		"AT_pre" => reduce_dim(at_pre),
		"ST" => reduce_dim(st),
		"ST_pre" => reduce_dim(st_pre),
		"AT_spring" => reduce_dim(filter(row -> row.season == "spring", at)),
		"AT_summer" => reduce_dim(filter(row -> row.season == "summer", at)),
		"AT_winter" => reduce_dim(filter(row -> row.season == "winter", at)),
		"ST_spring" => reduce_dim(filter(row -> row.season == "spring", st)),
		"ST_summer" => reduce_dim(filter(row -> row.season == "summer", st)),
		"ST_winter" => reduce_dim(filter(row -> row.season == "winter", st)),
		"spring" => reduce_dim(filter(row -> row.season == "spring", [at; st])),
		"summer" => reduce_dim(filter(row -> row.season == "summer", [at; st])),
		"winter" => reduce_dim(filter(row -> row.season == "winter", [at; st])),
	)

	env_reduced.position = [s[4] for s in env_reduced.id]
	env_reduced.region = [s[1] for s in env_reduced.id]
	env_reduced.site = [s[2:3] for s in env_reduced.id]
	env_reduced.year = fill(year, nrow(env_reduced))

	return env_reduced
end

df_2020 = hcat(create_env(at_date, st_date, "2020", ids), split_df[1], makeunique = true)
df_2021 = hcat(create_env(at_date, st_date, "2021", ids), split_df[2], makeunique = true)
df_2022 = hcat(create_env(at_date, st_date, "2022", ids), split_df[3], makeunique = true)

plot_input_df = [df_2020; df_2021; df_2022]

class_names = class_mean[!, 1]

marker_types = [:circle, :diamond]
class = class_names[5]

reshaped_input = [
	reshape_df(split_df[1], "2020");
	reshape_df(split_df[2], "2021");
	reshape_df(split_df[3], "2022")
]

function reshape_monthly_df(df)
	result = stack(df)
	repeated_dfs = [hcat(result, DataFrame(month = fill(i, nrow(result)))) for i in 1:12]
	repeated_df = vcat(repeated_dfs...)
	repeated_df.site = getindex.(split.(repeated_df.id, "_"), 1)
	repeated_df.id = repeated_df.site .* "_" .* [s[3:4] for s in repeated_df.year] .* "_" .* string.(repeated_df.month)

	env = env_monthYear
	env.id = env.site .* "_" .* [s[3:4] for s in env.year] .* "_" .* env.month
	leftjoin!(repeated_df, env, on = :id, makeunique = true)
end

reshaped_monthly = [
	reshape_monthly_df(split_df[1]);
	reshape_monthly_df(split_df[2]);
	reshape_monthly_df(split_df[3])
]

