# calculate mean and skip missing values
function mean_skipmissing(x)
    non_missing = skipmissing(x)
    return isempty(non_missing) ? missing : mean(non_missing)
end

# format column as date
function format_date(df, datecol)
	date_format = Dates.DateFormat("y-m-dTH:M:SZ")
	df[:, datecol] = replace.(df[:, datecol], r"\.(.*)" => "")
	datetime = Dates.DateTime.(df[:, datecol], date_format)
	#df[!, Not(datecol)] = Number.(df[!, Not(datecol)])

	df.year = string.(Dates.year.(datetime))
	df.month = string.(Dates.month.(datetime))
	df.day = string.(Date.(datetime))

	df.season = replace(string.(df.month)) do s
		r = s == "12" || s == "1" || s == "2" ? "winter" : s
		r = s == "3" || s == "4" || s == "5" ? "spring" : r
		r = s == "6" || s == "7" || s == "8" ? "summer" : r
		s == "9" || s == "10" || s == "11" ? "autumn" : r
	end
	df
end

# aggregate dataframe by column (mean)
function agg_function(df, aggcol)
	numcols = names(df, findall(x -> eltype(x) != String, eachcol(df)))
	result = combine(groupby(df, aggcol),
		aggcol => first => "Group",
		numcols .=> mean_skipmissing .=> numcols)
	select!(result, Not(aggcol))
end

# reshape dataframes
function reshape(at, st)
	numcols = names(at, findall(x -> eltype(x) != String, eachcol(at)))
	result_at = stack(at, numcols, [:Group],
		variable_name = "site", value_name = :AT)

	numcols = names(st, findall(x -> eltype(x) != String, eachcol(st)))
	result_st = stack(st, numcols, [:Group],
		variable_name = "site", value_name = :ST)

	innerjoin(result_at, result_st, on = ["Group", "site"])
end

# bind environmental data dataframes together
function bind_env(at, st)
	env_bind = [at; st]
	env_bind.env = vcat(fill.(["AT"; "ST"], [nrow(at); nrow(st)])...)
	env_bind.var = env_bind[:, "Group"] .* env_bind.env
	env_bind
end

# reduce dimensions (pc1)
function reduce_dim(input)
	df = DataFrame(map(col -> coalesce.(col, 0.0), eachcol(input)), names(input))
	numcols = names(df, findall(x -> eltype(x) <: Number, eachcol(df)))
	input_matrix = Matrix(df[:, numcols])
	μ = mean(input_matrix, dims = 1)
	centered = input_matrix .- μ
	model = fit(PCA, centered; maxoutdim = 1)
	output_matrix = predict(model, input_matrix)
	vec(output_matrix)
end

# transpose dataframe
function transpose_df(df)
	names_col = df[!, 1]
	transposed_df = permutedims(select(df, Not(1)))
	transposed_df = rename!(transposed_df, names_col)
	transposed_df.id = names(class_mean)[2:end]
	transposed_df.year = "20" .* [s[6:7] for s in transposed_df.id]
	grouped = groupby(transposed_df, :year)
	[DataFrame(group) for group in grouped]
end

# reshape dataframe
function reshape_df(df, year)
	result = stack(df)
	env = create_env(at_date, st_date, year, ids)
	env.id = env.id .* "_" .* [s[3:4] for s in env.year]
	leftjoin!(result, env, on = :id, makeunique = true)
end
