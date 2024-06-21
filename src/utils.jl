
function format_nums(x, digs)
	if isa(x, String) return x end
	function round_float(x::Float64, digs::Int)::String
		x = round(x, sigdigits=digs)
		return (string(x) * repeat("0", digs))[1:digs+1]
	end
 
	if isa(x, Quantity)
		unit = Measurements.unit(x) |> string
		return ustrip.(x)
		if isa(x, Measurement)
			return round_float(Measurements.value(x), digs) * L"\pm "*round_float(Measurements.uncertainty(x), digs)* L" \, \textrm{"*unit*"}"
		else
			return round_float(x, digs) * L"\, \textrm{"*unit*"}"
		end
	elseif isa(x, Measurement)
		return L""*round_float(Measurements.value(x), digs)*L"\pm "*round_float(Measurements.uncertainty(x), digs)
	elseif isa(x, Float64)
		return round_float(x, digs)
	end
end


function save_df_table(filename::String, df1::DataFrame, digs::Int=3)
	function round_float(x::Float64, digs::Int)::String
		str = floor(Int, x) |> string
		str2 = (string(x%1) * repeat("0", digs))[1:digs]
		return str*str2
	end
 
	df = copy(df1)
 
	for i in axes(df, 2)
		if isa(df[1, i], Quantity)
			unit = Unitful.unit(df[1,i]) |> string
			df[!, i] = ustrip.(df[!, i])
			if isa(df[1, i], Measurement)
				df[!, i] = [round_float(Measurements.value(x), digs) * L"\pm "*round_float(Measurements.uncertainty(x), digs)* L" \, \textrm{"*unit*"}" for x in df[!, i]]
			else
				df[!, i] = [round_float(x, digs) * L"\, \textrm{$unit}" for x in df[!, i]]
			end
		elseif isa(df[1, i], Measurement)
			df[!, i] = [L""*round_float(Measurements.value(x), digs)*L"\pm "*round_float(Measurements.uncertainty(x), digs) for x in df[!, i]]
		elseif isa(df[1, i], Float64)
			df[!, i] = [round(x, digs) for x in df[!, i]]
		end
	end

	# get info from show function through buffer
	io = IOBuffer()
	show(io, MIME("text/latex"), df)
	latex_str = String(take!(io))
	latex_str = split(latex_str, "\n")
	# latex_str = split.(latex_str, "&")
	 for i in eachindex(latex_str)
		if contains(latex_str[i], "&")
			latex_str[i] = join(split(latex_str[i], "&")[2:end], "&")
		end
	 end
	latex_str = latex_str[vcat(1:3, 6:end)]
	 latex_str = join(latex_str, "\n")
	 #save info to file
	 open(filename * ".txt", "w") do f
		 write(f, latexify(df1, env=:table, fmt=x -> format_nums(x, digs)))#latex_str)
	 end
	 return latex_str
 end

function save_df_table1(path, df, digs=3)
	df = deepcopy(df)
	display(df)
	for i in axes(df, 2)
		if isa(df[1, i], Number) && !isa(df[1, i], Integer)
			df[!, i] .= round.(typeof(df[1,i]), df[!, i], sigdigits=digs)
		end
	end
	display(df)
	write(path, latexify(df, env=:table, fmt=x -> format_nums(x, digs)))
end