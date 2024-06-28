palette = ["#5377C9", "#DF8A56", "#82CA70", "#F7F06D", "#9A90CB"]
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
