using Pkg
function installed()
  deps = Pkg.dependencies()
  installs = Dict{String, VersionNumber}()
  for (uuid, dep) in deps
    dep.is_direct_dep || continue
    dep.version === nothing && continue
    installs[dep.name] = dep.version
  end
  return installs
end
# Check if packages are installed, else install them
Packages = ["Plots","CSV", "DataFrames"]
installed_Packages = keys(installed())
for Package in Packages
  if !(Package in installed_Packages)
    try
      eval(Meta.parse("using $Package"))
    catch
      println("Package $Package was not found. Installation started")
      Pkg.add(Package)
      eval(Meta.parse("using $Package"))
    end
  else
    eval(Meta.parse("using $Package"))
  end
end

using Distributions
using LaTeXStrings
using RollingFunctions
using Statistics



# Pfade =============================================================================================================================================

# Ordner:
Speicherort_Plots = joinpath(@__DIR__, "Plots")
Datenverzeichnis  = joinpath(@__DIR__, "Data")

# Punkt 1 - Beschleunigung:
SO_abs_beschl            = joinpath(Datenverzeichnis,  "Beschleunigung_Ruhe.csv")
Speicherung_abs_beschl   = joinpath(Speicherort_Plots, "Absolute_Beschleunigung_Ruhe.png")
Speicherung_lin_beschl_x = joinpath(Speicherort_Plots, "Lineare_x_Beschleunigung_Ruhe.png")
Speicherung_lin_beschl_y = joinpath(Speicherort_Plots, "Lineare_y_Beschleunigung_Ruhe.png")
Speicherung_lin_beschl_z = joinpath(Speicherort_Plots, "Lineare_z_Beschleunigung_Ruhe.png")

# Punkt 2 - Übereinanderlegen der Kurven:
Speicherung_Abweichung_abs = joinpath(Speicherort_Plots, "Abweichung_abs.png")
Speicherung_Abweichung_x   = joinpath(Speicherort_Plots, "Abweichung_x.png")
Speicherung_Abweichung_y   = joinpath(Speicherort_Plots, "Abweichung_y.png")
Speicherung_Abweichung_z   = joinpath(Speicherort_Plots, "Abweichung_z.png")

# Punkt 3 - Histogramme:
Speicherung_Hist_Roh_abs = joinpath(Speicherort_Plots, "Histogramm_Roh_abs.png")
Speicherung_Hist_Roh_x   = joinpath(Speicherort_Plots, "Histogramm_Roh_x.png")
Speicherung_Hist_Roh_y   = joinpath(Speicherort_Plots, "Histogramm_Roh_y.png")
Speicherung_Hist_Roh_z   = joinpath(Speicherort_Plots, "Histogramm_Roh_z.png")
Speicherung_Hist_Geg_abs = joinpath(Speicherort_Plots, "Histogramm_Geg_abs.png")
Speicherung_Hist_Geg_x   = joinpath(Speicherort_Plots, "Histogramm_Geg_x.png")
Speicherung_Hist_Geg_y   = joinpath(Speicherort_Plots, "Histogramm_Geg_y.png")
Speicherung_Hist_Geg_z   = joinpath(Speicherort_Plots, "Histogramm_Geg_z.png")





# PUNKT 1 DER AUSWERTUNG ===========================================================================================================================================

function Block_1()
  # Lade Daten:
  Data_beschl   = CSV.read(SO_abs_beschl, DataFrame)

  # Erstelle Arrays mit x- & y-Werten:
  zeit         = Data_beschl[:, 1]
  lin_beschl_x = Data_beschl[:, 2]
  lin_beschl_y = Data_beschl[:, 3]
  lin_beschl_z = Data_beschl[:, 4]
  abs_beschl   = Data_beschl[:, 5]



  # ***********************************
  # ************* Punkt 1 *************
  # ***********************************
  
  # Parameter zum Glätten der Kurve:
  # Allgemeines:
  window_size_10   = 10
  window_size_100  = 100
  window_size_2001 = 2001
  # Absolute Beschleunigung:
  result10   = runmean(abs_beschl,   window_size_10)
  result100  = runmean(abs_beschl,   window_size_100)
  result2001 = runmean(abs_beschl,   window_size_2001)
  # Lineare Beschleunigung in x-Richtung
  res_x_10   = runmean(lin_beschl_x, window_size_10)
  res_x_100  = runmean(lin_beschl_x, window_size_100)
  res_x_2001 = runmean(lin_beschl_x, window_size_2001)
  # Lineare Beschleunigung in y-Richtung
  res_y_10   = runmean(lin_beschl_y, window_size_10)
  res_y_100  = runmean(lin_beschl_y, window_size_100)
  res_y_2001 = runmean(lin_beschl_y, window_size_2001)
  # Lineare Beschleunigung in z-Richtung
  res_z_10   = runmean(lin_beschl_z, window_size_10)
  res_z_100  = runmean(lin_beschl_z, window_size_100)
  res_z_2001 = runmean(lin_beschl_z, window_size_2001)

  # Berechne Mittelwert & Standardabweichung:
  # Absolute Beschleunigung:
  MW_abs_beschl = mean(abs_beschl)
  ST_abs_beschl = std(abs_beschl)
  println("Mittelwert absolute Beschleunigung: " * string(MW_abs_beschl))
  println("STABW absolute Beschleunigung: " * string(ST_abs_beschl))
  println("")
  # Lineare Beschleunigung in x-Richtung
  MW_lin_beschl_x = mean(lin_beschl_x)
  ST_lin_beschl_x = std(lin_beschl_x)
  println("Mittelwert lineare Beschleunigung in x: " * string(MW_lin_beschl_x))
  println("STABW lineare Beschleunigung in x: " * string(ST_lin_beschl_x))
  println("")
  # Lineare Beschleunigung in y-Richtung
  MW_lin_beschl_y = mean(lin_beschl_y)
  ST_lin_beschl_y = std(lin_beschl_y)
  println("Mittelwert lineare Beschleunigung in y: " * string(MW_lin_beschl_y))
  println("STABW lineare Beschleunigung in y: " * string(ST_lin_beschl_y))
  println("")
  # Lineare Beschleunigung in z-Richtung
  MW_lin_beschl_z = mean(lin_beschl_z)
  ST_lin_beschl_z = std(lin_beschl_z)
  println("Mittelwert lineare Beschleunigung in z: " * string(MW_lin_beschl_z))
  println("STABW lineare Beschleunigung in z: " * string(ST_lin_beschl_z))
  println("")

  # # Generiere Plot für absolute Beschleunigung:
  # Plots.scatter(zeit[2000:end], abs_beschl[2000:end], markerstrokewidth=0,title="Absolute Beschleunigung - Rohdaten mit Glättung", xlabel="Zeit [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", grid=false, dpi=300)
  # plot!(zeit[2000:end], result10[2000:end],   label = "Geglättete Daten, Window size = 10",   grid=false, dpi=300, linewidth=2)
  # plot!(zeit[2000:end], result100[2000:end],  label = "Geglättete Daten, Window size = 100",  grid=false, dpi=300, linewidth=2)
  # plot!(zeit[3000:end], result2001[3000:end], label = "Geglättete Daten, Window size = 2001", grid=false, dpi=300, linewidth=2, linecolor=:black)
  # hline!([MW_abs_beschl], label="MW = " * string(MW_abs_beschl), color=:red)
  # savefig(Speicherung_abs_beschl)
  # # Generiere Plot für lineare Beschleunigung in x-Richtung:
  # Plots.scatter(zeit[2000:end], lin_beschl_x[2000:end], markerstrokewidth=0,title="Lineare x-Beschleunigung - Rohdaten mit Glättung", xlabel="Zeit [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", grid=false, dpi=300)
  # plot!(zeit[2000:end], res_x_10[2000:end],   label = "Geglättete Daten, Window size = 10",   grid=false, dpi=300, linewidth=2)
  # plot!(zeit[2000:end], res_x_100[2000:end],  label = "Geglättete Daten, Window size = 100",  grid=false, dpi=300, linewidth=2)
  # plot!(zeit[3000:end], res_x_2001[3000:end], label = "Geglättete Daten, Window size = 2001", grid=false, dpi=300, linewidth=2, linecolor=:black)
  # hline!([MW_lin_beschl_x], label="MW = " * string(MW_lin_beschl_x), color=:red)
  # savefig(Speicherung_lin_beschl_x)
  # # Generiere Plot für lineare Beschleunigung in y-Richtung:
  # Plots.scatter(zeit[2000:end], lin_beschl_y[2000:end], markerstrokewidth=0,title="Lineare y-Beschleunigung - Rohdaten mit Glättung", xlabel="Zeit [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", grid=false, dpi=300, legend=:bottomright)
  # plot!(zeit[2000:end], res_y_10[2000:end],   label = "Geglättete Daten, Window size = 10",   grid=false, dpi=300, linewidth=2)
  # plot!(zeit[2000:end], res_y_100[2000:end],  label = "Geglättete Daten, Window size = 100",  grid=false, dpi=300, linewidth=2)
  # plot!(zeit[3000:end], res_y_2001[3000:end], label = "Geglättete Daten, Window size = 2001", grid=false, dpi=300, linewidth=2, linecolor=:black)
  # hline!([MW_lin_beschl_y], label="MW = " * string(MW_lin_beschl_y), color=:red)
  # savefig(Speicherung_lin_beschl_y)
  # # Generiere Plot für lineare Beschleunigung in z-Richtung:
  # Plots.scatter(zeit[2000:end], lin_beschl_z[2000:end], markerstrokewidth=0,title="Lineare z-Beschleunigung - Rohdaten mit Glättung", xlabel="Zeit [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", grid=false, dpi=300)
  # plot!(zeit[2000:end], res_z_10[2000:end],   label = "Geglättete Daten, Window size = 10",   grid=false, dpi=300, linewidth=2)
  # plot!(zeit[2000:end], res_z_100[2000:end],  label = "Geglättete Daten, Window size = 100",  grid=false, dpi=300, linewidth=2)
  # plot!(zeit[3000:end], res_z_2001[3000:end], label = "Geglättete Daten, Window size = 2001", grid=false, dpi=300, linewidth=2, linecolor=:black)
  # hline!([MW_lin_beschl_z], label="MW = " * string(MW_lin_beschl_z), color=:red)
  # savefig(Speicherung_lin_beschl_z)
    




  # ***********************************
  # ************* Punkt 2 *************
  # ***********************************

  # Berechne Mittelwerte und Standardabweichung in den vergrößerten Bereichen:
  # Absolute Beschleunigung:
  MW_abs_beschl_vergr = mean(abs_beschl[40000:50000])
  ST_abs_beschl_vergr = std(abs_beschl[40000:50000])
  println("Mittelwert absolute Beschleunigung (vergr.): " * string(MW_abs_beschl_vergr))
  println("STABW absolute Beschleunigung (vergr.): " * string(ST_abs_beschl_vergr))
  println("")
  # Lineare Beschleunigung in x-Richtung
  MW_lin_beschl_x_vergr = mean(lin_beschl_x[40000:50000])
  ST_lin_beschl_x_vergr = std(lin_beschl_x[40000:50000])
  println("Mittelwert lineare Beschleunigung in x (vergr.): " * string(MW_lin_beschl_x_vergr))
  println("STABW lineare Beschleunigung in x (vergr.): " * string(ST_lin_beschl_x_vergr))
  println("")
  # Lineare Beschleunigung in y-Richtung
  MW_lin_beschl_y_vergr = mean(lin_beschl_y[40000:50000])
  ST_lin_beschl_y_vergr = std(lin_beschl_y[40000:50000])
  println("Mittelwert lineare Beschleunigung in y (vergr.): " * string(MW_lin_beschl_y_vergr))
  println("STABW lineare Beschleunigung in y (vergr.): " * string(ST_lin_beschl_y_vergr))
  println("")
  # Lineare Beschleunigung in z-Richtung
  MW_lin_beschl_z_vergr = mean(lin_beschl_z[40000:50000])
  ST_lin_beschl_z_vergr = std(lin_beschl_z[40000:50000])
  println("Mittelwert lineare Beschleunigung in z (vergr.): " * string(MW_lin_beschl_z_vergr))
  println("STABW lineare Beschleunigung in z (vergr.): " * string(ST_lin_beschl_z_vergr))

  # Generiere die Plots zu den Vergrößersten Abschnitten:
  # Absolute Beschleunigung
  Plots.plot(zeit[40000:50000], result2001[40000:50000], title= "Vergr. Abschnitt - Abs. Beschleunigung",     xlabel="Zet [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", grid=false, dpi=300)
  hline!([MW_abs_beschl_vergr], label=L"\mathrm{MW = }" * string(MW_abs_beschl_vergr) * L"\frac{m}{s^2}", color=:red)
  annotate!(430, 0.137, annotationfontsize=8, L"\mathrm{STABW = } " *string(ST_abs_beschl_vergr) * L"\frac{m}{s^2}")
  savefig(Speicherung_Abweichung_abs)
  # In x-Richtung
  Plots.plot(zeit[40000:50000], res_x_2001[40000:50000], title= "Vergr. Abschnitt - Lin. Beschleunigung in x", xlabel="Zet [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", legend=:top, grid=false, dpi=300)
  annotate!(450, 0.084, annotationfontsize=8, L"\mathrm{STABW = } " *string(ST_lin_beschl_x_vergr) * L"\frac{m}{s^2}")
  hline!([MW_lin_beschl_x_vergr], label=L"\mathrm{MW = }" * string(MW_lin_beschl_x_vergr) * L"\frac{m}{s^2}", color=:red)
  savefig(Speicherung_Abweichung_x)
  # In y-Richtung
  Plots.plot(zeit[40000:50000], res_y_2001[40000:50000], title= "Vergr. Abschnitt - Lin. Beschleunigung in y", xlabel="Zet [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", legend=:bottomright, grid=false, dpi=300)
  annotate!(475, 0.016, annotationfontsize=8, L"\mathrm{STABW = } " *string(ST_lin_beschl_y_vergr) * L"\frac{m}{s^2}")
  hline!([MW_lin_beschl_y_vergr], label=L"\mathrm{MW = }" * string(MW_lin_beschl_y_vergr) * L"\frac{m}{s^2}", color=:red)
  savefig(Speicherung_Abweichung_y)
  # In z-Richtung
  Plots.plot(zeit[40000:50000], res_z_2001[40000:50000], title= "Vergr. Abschnitt - Lin. Beschleunigung in z", xlabel="Zet [s]", ylabel=L"\mathrm{Beschleunigung [} \frac{m}{s^2} \mathrm{]}", legend=:bottomright, grid=false, dpi=300)
  annotate!(475, 0.097, annotationfontsize=8, L"\mathrm{STABW = } " *string(ST_lin_beschl_z_vergr) * L"\frac{m}{s^2}")
  hline!([MW_lin_beschl_z_vergr], label=L"\mathrm{MW = }" * string(MW_lin_beschl_z_vergr) * L"\frac{m}{s^2}", color=:red)
  savefig(Speicherung_Abweichung_z)





  # ***********************************
  # ************* Punkt 3 *************
  # ***********************************

  # Gaußfunktion:
  #gauss_1(x) = 1500 * exp(-((x-MW_abs_beschl_vergr)^2) / ((2*ST_abs_beschl_vergr)^2))
  #x = zeit[40000:50000]
  #ys=gauss_1.(x)
  #y_1=map(gauss_1, x)
  #println(ys[100:200])

  # Lad

  # Histogramme für Rohdaten:
  #Absolute Beschleunigung
  histogram(abs_beschl[40000:50000], grid=false, title="Histogramm Rohdaten - Absolute Beschelunigung")
  savefig(Speicherung_Hist_Roh_abs)
  # Beschleunigung in x-Richtung
  histogram(lin_beschl_x[40000:50000], grid=false, title="Histogramm Rohdaten - Lin. Beschelunigung in x")
  savefig(Speicherung_Hist_Roh_x)
  # Beschleunigung in y-Richtung
  histogram(lin_beschl_y[40000:50000], grid=false, title="Histogramm Rohdaten - Lin. Beschelunigung in y")
  savefig(Speicherung_Hist_Roh_y)
  # Beschleunigung in z-Richtung
  histogram(lin_beschl_z[40000:50000], grid=false, title="Histogramm Rohdaten - Lin. Beschelunigung in z")
  savefig(Speicherung_Hist_Roh_z)

  # Histogramme für geglätteten Werte:
  #Absolute Beschleunigung
  histogram(result2001[40000:50000], grid=false, title="Histogramm Geglättete Daten - Abs. Beschelunigung")
  savefig(Speicherung_Hist_Geg_abs)
  # Beschleunigung in x-Richtung
  histogram(res_x_2001[40000:50000], grid=false, title="Histogramm Geglättete Daten - x Beschelunigung")
  savefig(Speicherung_Hist_Geg_x)
  # Beschleunigung in y-Richtung
  histogram(res_y_2001[40000:50000], grid=false, title="Histogramm Geglättete Daten - y Beschelunigung")
  savefig(Speicherung_Hist_Geg_y)
  # Beschleunigung in z-Richtung
  h=histogram(res_z_2001[40000:50000], grid=false, title="Histogramm Geglättete Daten - z Beschelunigung")
  #savefig(Speicherung_Hist_Geg_z)

end



# Start der Auswertung =============================================================================================================================================



Block_1()