palette = ["#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"]
palette_continious = [colorant"white", colorant"#F7F06D", colorant"#DF8A56", colorant"#9A90CB", colorant"#5377C9"]
function custom_colormap(x)
	n = length(palette_continious)
	idx = Int(floor(1 + x * (n - 1)))
	t = x * (n - 1) - (idx - 1)
	return (1 - t) * palette_continious[idx] + t * palette_continious[clamp(idx + 1, 1, n)]
end

palette_continious2 = [colorant"#5377C9", colorant"#9A90CB", colorant"#DF8A56"]
function custom_colormap2(x)
	n = length(palette_continious2)
	idx = Int(floor(1 + x * (n - 1)))
	t = x * (n - 1) - (idx - 1)
	return (1 - t) * palette_continious2[idx] + t * palette_continious2[clamp(idx + 1, 1, n)]
end


month_levels = [
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec",
]

season_intercepts = vcat(
	collect(1:59),
	collect(152:243),
	collect(334:366),
)

month_ticks = collect(15:30:350)
