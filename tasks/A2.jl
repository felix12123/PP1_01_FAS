using Measurements
using CSV
using DataFrames
using Unitful
using Plots

Mm = Measurements
function A2()
	Faden_Länge = 1.80u"m"
	# load data
	data_file = "Data\\PendelSmartphone182cm.csv"
	data = CSV.File(data_file, delim=";") |> DataFrame
	rename!(data, [:t, :x, :y, :z, :abs])
	

	# create a view of the different acceleration components
	visualize_acc_comps(data)

	# get period lengths
	Ts = typeof((1.0 ± 1.0)u"s")[]
	append!(Ts, freq_par(data)[1])
	append!(Ts, freq_fit(data, Measurements.value(Ts[1]) |> ustrip))
	append!(Ts, freq_fft(data[1:end÷1, :]))
	append!(Ts, freq_zeros(data))
	append!(Ts, freq_min_max(data))

	# calculate g
	# T = 2π ⋅ √(l/g)  ⇒  g = l⋅4π²/T²
	g(T) = (Faden_Länge ± 0.03u"m") * 4pi^2 / (T .^ 2)
	g_ohne_sys(T) = Faden_Länge * 4pi^2 / (T .^ 2)
	gs = g_ohne_sys.(Ts)
	
	# save results
	methods=["Parable", "Fit", "FFT", "Zeros", "Maxima"]
	Δg_zuf=Mm.uncertainty.(gs)
	Δg_sys=Mm.uncertainty.(g.(Mm.value.(Ts)))
	results = DataFrame(method=methods, T=Ts, g=g.(Ts), Δg_zuf=Δg_zuf, Δg_sys=Δg_sys)
	save_df_table("Tables\\All_Results", results)
	println("T only has random error.")
	display(results)

	scatter(methods, gs, label="g", xlabel="Methode", ylabel="g", title="", legend=:topleft)
	hline!([9.808], label="g_lit")
	savefig("Plots\\g_methode")

	# visualize the period length and the standard deviation of the period length over time
	vis_T_std()
	
end