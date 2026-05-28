using DrWatson
@quickactivate "project"

include(srcdir("sir_model.jl"))
using .sir_model
using Random, StatsPlots, DataFrames, CSV, BenchmarkTools

function extract_metrics(df::DataFrame, N_total::Int)
    peak_I = maximum(df.I)
    t_peak = df.t[argmax(df.I)]
    final_R = df.R[end]
    final_R_share = final_R / N_total
    return (peak_I=peak_I, t_peak=t_peak, final_R_share=final_R_share)
end

tmax = 40.0
u0 = [990, 10, 0]
N_total = sum(u0)

base_beta = 0.05
base_c = 10.0
base_gamma = 0.25

Random.seed!(1234)

model_base = MakeSIRModel(u0, [base_beta, base_c, base_gamma])
activate(model_base)
sir_run(model_base, tmax)
data_base = out(model_base)

@df data_base plot(:t, [:S :I :R],
    labels=["S" "I" "R"],
    xlabel="Время", ylabel="Численность",
    title="Дискретно-событийная SIR (β=$base_beta, c=$base_c, γ=$base_gamma)")
savefig(plotsdir("sir_des_basic.png"))

CSV.write(datadir("sir_des_basic.csv"), data_base)

betas = [0.03, 0.05, 0.07]
results_beta = []
for β in betas
    p = [β, base_c, base_gamma]
    m = MakeSIRModel(u0, p)
    activate(m)
    sir_run(m, tmax)
    df = out(m)
    metrics = extract_metrics(df, N_total)
    push!(results_beta, (β=β, peak_I=metrics.peak_I, t_peak=metrics.t_peak,
                         final_R_share=metrics.final_R_share))
end
df_beta = DataFrame(results_beta)
CSV.write(datadir("sensitivity_beta.csv"), df_beta)

p_beta = plot(df_beta.β, df_beta.peak_I, marker=:circle, label="Пик I")
plot!(p_beta, df_beta.β, df_beta.final_R_share .* N_total, marker=:square, label="Итоговое R")
xlabel!(p_beta, "β"); ylabel!(p_beta, "Численность")
title!(p_beta, "Влияние β (c=$base_c, γ=$base_gamma)")
savefig(plotsdir("sensitivity_beta.png"))

cs = [5.0, 10.0, 15.0]
results_c = []
for c in cs
    p = [base_beta, c, base_gamma]
    m = MakeSIRModel(u0, p)
    activate(m)
    sir_run(m, tmax)
    df = out(m)
    metrics = extract_metrics(df, N_total)
    push!(results_c, (c=c, peak_I=metrics.peak_I, t_peak=metrics.t_peak,
                      final_R_share=metrics.final_R_share))
end
df_c = DataFrame(results_c)
CSV.write(datadir("sensitivity_c.csv"), df_c)

p_c = plot(df_c.c, df_c.peak_I, marker=:circle, label="Пик I")
plot!(p_c, df_c.c, df_c.final_R_share .* N_total, marker=:square, label="Итоговое R")
xlabel!(p_c, "c (частота контактов)"); ylabel!(p_c, "Численность")
title!(p_c, "Влияние c (β=$base_beta, γ=$base_gamma)")
savefig(plotsdir("sensitivity_c.png"))

gammas = [0.1, 0.25, 0.5]
results_gamma = []
for γ in gammas
    p = [base_beta, base_c, γ]
    m = MakeSIRModel(u0, p)
    activate(m)
    sir_run(m, tmax)
    df = out(m)
    metrics = extract_metrics(df, N_total)
    push!(results_gamma, (γ=γ, peak_I=metrics.peak_I, t_peak=metrics.t_peak,
                          final_R_share=metrics.final_R_share))
end
df_gamma = DataFrame(results_gamma)
CSV.write(datadir("sensitivity_gamma.csv"), df_gamma)

p_gamma = plot(df_gamma.γ, df_gamma.peak_I, marker=:circle, label="Пик I")
plot!(p_gamma, df_gamma.γ, df_gamma.final_R_share .* N_total, marker=:square, label="Итоговое R")
xlabel!(p_gamma, "γ (скорость выздоровления)"); ylabel!(p_gamma, "Численность")
title!(p_gamma, "Влияние γ (β=$base_beta, c=$base_c)")
savefig(plotsdir("sensitivity_gamma.png"))

u0_large = [9990, 10, 0]
model_large = MakeSIRModel(u0_large, [base_beta, base_c, base_gamma])
activate(model_large)
@benchmark sir_run($model_large, 40.0) samples=3
