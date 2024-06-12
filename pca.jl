using PlotlyJS          # interface to the [plotly.js] visualization library
using Tar               # tar archive utilities
using MultivariateStats # for multivariate statistics and data analysis

# create functions
function pca(input, group, group2)

	# train PCA model
	model = fit(PCA, input; maxoutdim = 3)
	total_var = tprincipalvar(model::PCA)

	# apply PCA model 
	matrix = predict(model, input)
	pca_result = DataFrame(transpose(matrix), :auto)
	pca_result.group = group
	pca_result.group2 = group2
	# plot results
	PlotlyJS.plot(
		pca_result,
		x = :x1, y = :x2, z = :x3, color = :group, symbol = :group2,
		kind = "scatter3d", mode = "markers+text",
		labels = attr(; [Symbol("x", i) => "PC $i" for i in 1:3]...),
		Layout(
			title = "Total explained variance: $(round(total_var, digits=0))",
		),
	)
end

# create input matrix
# mean
input = Matrix(df_mean[1:end, 7:end])
labels = names(df_mean[1:end, 7:end])
position = [s[4] for s in labels]
region = [s[1] for s in labels]
site = [s[2:3] for s in labels]

# apply function
pca(input, site, region)
#E16A

# create input matrix
input = Matrix(df_absolute[1:end, 7:end])
labels = names(df_absolute[1:end, 7:end])
position = [s[4] for s in labels]
region = [s[1] for s in labels]
site = [s[2:3] for s in labels]

# apply function
pca(input, site)