using MixedModels       # providing capabilities linear and generalized linear mixed-effect models
using MixedModelsMakie  # special graphics for mixed models


# mixed models
form = @formula(value ~ 1 + AT + ST + (1 | variable) + (1 | year) + (1 | id));
gm1 = fit(MixedModel, form, reshaped_input)::MixedModel

class_intercept = DataFrame([ranefinfo(gm1, :variable)])
class_intercept_df = DataFrame(
	"class" => class_intercept[1, 2],
	"ranef" => vec(class_intercept[1, 3]),
	"stddev" => vec(class_intercept[1, 4])
)

class_intercept_df.ranef .- class_intercept_df.stddev

Gadfly.plot(
	class_intercept_df,
	x = :class,
	y = :ranef,
    ymin = class_intercept_df.ranef .- class_intercept_df.stddev,
    ymax = class_intercept_df.ranef .+ class_intercept_df.stddev,
	size = [1.5mm],
    yintercept=[-5, 0, 5],
    Geom.hline(color=["black","black", "black"], size=[0.1mm,0.3mm, 0.1mm]),
	Geom.point,
    Geom.errorbar,
	Guide.xlabel("Class"),
	Guide.ylabel("Intercept"),
	Theme(
		background_color = "white",
		default_color = "#5377C9",
	),
)

form = @formula(value ~ 1 + AT + ST + (1 | year/variable) + (1 | id));
gm2 = fit(MixedModel, form, reshaped_input)::MixedModel
raneffects = DataFrame(raneftables(gm2)[1])

intercept_df = DataFrame(
    "year" => getindex.(raneffects[:, 1], 1),
	"class" => getindex.(raneffects[:, 1], 2),
	"ranef" => raneffects[:, 2]
)

Gadfly.plot(
	intercept_df,
	x = :class,
	y = :ranef,
    color = :year,
    alpha = [0.9],
	size = [1.5mm],
    yintercept=[0],
    Geom.hline(color=["black"], size=[0.3mm]),
	Geom.point,
	Guide.xlabel("Class"),
	Guide.ylabel("Intercept"),
    Scale.color_discrete_manual("#5377C9", "#DF8A56", "#82CA70"),
	Theme(
		background_color = "white",
		default_color = "#5377C9",
	),
)

