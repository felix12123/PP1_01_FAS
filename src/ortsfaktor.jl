# These functions are used to calculate the local factor from the measured values.


# quick visualisation of the acceleration components
function visualize_acc_comps(data)
	plot1 = plot(data.t*1u"s", uconvert.(u"cm/s^2", data.x*1u"m/s^2"), title="x-Komponente", xlabel="Zeit", ylabel="a", fontfamily="Computer Modern")
	plot2 = plot(data.t*1u"s", uconvert.(u"cm/s^2", data.y*1u"m/s^2"), title="y-Komponente", xlabel="Zeit", ylabel="a", fontfamily="Computer Modern")
	plot3 = plot(data.t*1u"s", uconvert.(u"cm/s^2", data.z*1u"m/s^2"), title="z-Komponente", xlabel="Zeit", ylabel="a", fontfamily="Computer Modern")
	plot4 = plot(data.t*1u"s", uconvert.(u"cm/s^2", data.abs*1u"m/s^2"), title="Absolutwert", xlabel="Zeit", ylabel="a", fontfamily="Computer Modern")

	l = @layout [a b; c d]
	ges_plot = plot(plot1, plot2, plot3, plot4, layout=l, dpi=300, left_margin=3Plots.mm, bottom_margin=3Plots.mm, size=(let l=800; (l, 9/16*l) end))
	savefig(ges_plot, "Plots\\Acc_Comps")
end

# here the frequency is determined by a fit over the whole data at once
function freq_fit(data, freqguess::Float64=0.0)
	println("\nTOTAL FIT AUSWERTUNG ======================================")
	if freqguess == 0 freqguess = 2.625 end
	
	model(x, p) = (p[1] .+ p[2] .* x) .* abs.(sin.(p[3] .* x .+ p[4])) .+ p[5]
	p0 = [0.18, 0.0, freqguess*0.84, 0.3, 0]
	fit = LsqFit.curve_fit(model, data.t, data.abs, p0)
	fitdata = model(data.t, fit.param)

	param_units = [u"m/s^2", u"m/s", u"1/s", 1, u"m/s^2"]
	params = (fit.param .± stderror(fit)) .* param_units
	params[1] = uconvert(u"mm/s^2", params[1])
	params[2] = uconvert(u"mm/s", params[2])
	params[3] = uconvert(u"s^-1", params[3])
	params[5] = uconvert(u"mm/s^2", params[5])

	# output fit parameters and save them in tex table
	df_param = DataFrame(Parameter=["a", "b", "c", "d", "e"], Value=params)
	println("Parameters for Fit:")
	display(df_param)
	save_df_table("Tables\\Tot_Fit", df_param)

	# output T
	T = 2pi/params[3]
	println("T = ", T)

	# Create Plot to visualize solution
	plot1 = plot(data.t*1u"s",
								data.abs * 1u"m/s^2",
								linewidth=3,
								dpi=300,
								title="Absolute Beschleunigung",
								label="Messwerte",
								xlabel="Zeit",
								ylabel="Beschleunigung")
	plot!(data.t, fitdata, label="Fit", linecolor=:black)
	savefig(plot1, "Plots\\Fit")

	# intervall = 1:div(length(data.t), 500)
	# x = data.t[intervall] |> eachindex
	# ys = [data.y[intervall], abs.(fft(data.y))[intervall]]
	
	return T
end

# here the frequency is determined by a combination of rough estimates
# of peaks a\nnd a parable fit to increase the precision
function freq_par(data)
	println("\nPARABEL FIT AUSWERTUNG ======================================")

	# datag ist die geglättete variante von data
	datag = copy(data)
	datag.y = runmean(datag.y, 4)
	mindist = 0.5 / (datag.t[3] - datag.t[2]) |> floor |> Int
	peaks = Findpeaks.findpeaks(datag.y, min_prom = 0.05, min_dist=mindist) |> sort

	# Model for parable fit
	model(x, p) = p[1] .* (x .- p[2]) .^ 2 .+ p[3]
	
	# Container to store the fitted Parables
	parables = []
	maxima = []

	# Define size of region for Fit
	rad = (peaks[2] - peaks[1]) / 4 |> floor |> Int

	for peak in peaks
		inds = max(1, peak-rad):min(length(data.t), peak+rad)
		x = data.t[inds]
		y = data.abs[inds]
		p0 = [1.0, datag.t[peak], datag.y[peak]]
		
		fit = LsqFit.curve_fit(model, x, y, p0)
		params = fit.param .± stderror(fit)
		append!(parables, [params])
		append!(maxima, [params[2]])
	end
	
	plot1 = plot(data.t, data.abs, label="Messwerte", linewidth=2, title="Parabel Fits")
	# Parabeln einzeichnen:
	for i in eachindex(peaks)
		inds = max(1, i-rad):min(length(data.t), i+rad)
		x = data.t[inds]
		y = model(x, Measurements.value.(parables[i]))
		plot!(x, y, label="", linecolor=:black)
		scatter!([parables[i][2].val], [parables[i][3].val], label="", dpi = 300, color=:orange)
	end
	sort!(maxima)
	distances = maxima[2:end] .- maxima[1:end-1]

	println("mean dist = ", mean(distances))
	T = 1u"s"*(mean(distances) + (0 ± std(Measurements.value.(distances))))
	println("T = ", T)
	

	savefig(plot1, "Plots\\Parbel")

	return T, maxima
end


# here the frequency is determined by the FFT of the data
function freq_fft(data)
	println("\nFOURIER TRAFO AUSWERTUNG =================================")

	data = data
	
	sampling_rate = round(1/(data.t[2]-data.t[1])) |> Int

	y = data.y

	F = abs.(fft(y) |> fftshift)
	freqs = fftshift(fftfreq(length(y), sampling_rate))

	model(x,p) = p[1] .+ p[2]  ./ ((x .- p[3])  .^ 2 .+ p[4]^2) .* p[4]^2
	p0=[0.0, 1300.0, 0.3, 0.1]
	fit = curve_fit(model, freqs[end÷2:end], F[end÷2:end], p0)
	
	# darstellung der fft und des fits
	# plot(freqs[end÷2:end], F[end÷2:end], xlims=(0, 1), dpi=300, title="FFT der Beschleunigung", xlabel="Frequenz", ylabel="Amplitude")
	# plot!(freqs[end÷2]:0.001:freqs[end], model(freqs[end÷2]:0.001:freqs[end], fit.param)) |> display

	# Automatisches Identifizieren von dominanten Frequenzkomponenten
	peaks = findpeaks(vcat(F, -F), min_prom=maximum(abs.(F))/25, threshold=maximum(abs.(F))/1000) .% size(F, 1)

	if peaks[1] == 0 peaks = peaks[2:end] end

	# Die Dominanteste Frequenzkomponente ist die schwingungs frequenz
	# T = 1/mean([freqs[(peaks[1])], freqs[(peaks[2])]]) * 1u"s"
	T = 1/freqs[peaks[2]] ± 2*fit.param[4] |> abs
	println("T = ", T)
	println("g = ", 4pi^2 * 1.82 / T^2)

	
	x_max = maximum(abs.(freqs[peaks])) * 2
	plot1 = plot(freqs, F, xlim=(-x_max,x_max))
	scatter!(freqs[peaks], F[peaks])

	return abs(T) * 1u"s"
end
# i=10000;j=2;data_file = "Data\\PendelSmartphone182cm.csv";data = CSV.File(data_file, delim=";") |> DataFrame; rename!(data, [:t, :x, :y, :z, :abs]); freq_fft(data[end÷i:end÷j, :])

# here the frequency is determined by the minima and maxima of the acceleration
function freq_min_max(data)
	data = deepcopy(data)
	data.y = runmean(data.y, 250)
	mindist = 0.5 / (data.t[3] - data.t[2]) |> floor |> Int
	dips = findpeaks(-data.y, min_prom=max(data.y...)/10, min_dist=mindist) |> sort

	distances = data.t[dips[2:end]] .- data.t[dips[1:end-1]]
	
	T = distances |> mean
	T = T ± std(2*distances)
	
	return T *1u"s"
end

# here the frequency is determined by the zeros of the acceleration
function freq_zeros(data)
	x = data.t
	y = data.y
	y = runmean(y, 50)

	vzw = y[1:end-1] .* y[2:end]

	zeros = findall(x -> x<0, vzw)

	T = 2 * ((diff(x[zeros]) |> mean |> abs) ± (std(diff(x[zeros])) |> abs))
	return T * 1u"s"
end


# visualize the period length and the standard deviation of the period length over time
function vis_T_std()
	# get data
	data_file = "Data\\PendelSmartphone182cm.csv"
	data = CSV.File(data_file, delim=";") |> DataFrame
	rename!(data, [:t, :x, :y, :z, :abs])

	# get period lengths
	maxima = [x.val for x in freq_par(data)[2]] 
	T_ps = diff(maxima)


	# to get the 95% confidence interval for the mean, we multiply the standard deviation by 1.96
	# color area between mean and std
	plot(runmean(T_ps, length(T_ps)), ribbon=1.96*runstd(T_ps, length(T_ps)), fillalpha=0.2, linecolor=:orange, fillcolor=:orange, label="σ_T", dpi=300, title="Abhängigkeit von T und σ_T von Anzahl Messwerten", xlabel="Verwendete Messwerte", ylabel="Periodendauer T [s]")

	savefig("Plots\\T_std")
end