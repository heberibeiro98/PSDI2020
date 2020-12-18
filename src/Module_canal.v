module canal(
			input  clock,
			input  reset,

			input [3:0] switches,

			input data_en,
			
			input [3:0] Nfreq,
			input [4:0] Nquant,

			output [6:0] RAM_coefs_addr,
			input  [7:0] RAM_coefs_dataout,

			input [17:0] data_in,

			output signed [17:0] data_out
);

wire filter_out, mux1_out, downsample_out, downsample_endataout, mux2_out, requantizer_out, mux3_out, interpol_out, mux4_out;

lowpass lowpass_m(
	.clock (clock),
	.reset (reset),
	.datain (data_in),
	.endata (data_en),
	.dataout (filter_out),
	.coefaddress (RAM_coefs_addr),
	.coefdata (RAM_coefs_dataout)
 );
 
mux mux1(
	.clock (clock),
	.sel (switches[0]),
	.datain(filter_out),
	.bypass(data_in),
	.outdata(mux1_out)
 );
 
downsample downsample_m(
	.clock (clock),    // Master clock
	.reset (reset),    // master reset, synchronous, active high
	.Nfreq (Nfreq),    // sampling rate divide factor
	.datain (mux1_out),   // input data
	.endatain (data_en), // in clock enable, Fs=48kHz
	.dataout (downsample_out),  // output data
	.endataout(downsample_endataout) // out clock enable, Fs = 48kHz/Nfreq
);

mux mux2(
	.clock (clock),
    .sel (switches[1]),
    .datain(downsample_out),
    .bypass(mux1_out),
    .outdata(mux2_out)
);

requantize requantizer_m(
  	.clock (clock), 		//Master clock
  	.reset (reset),		//master reset, synchronous, active high
  	.Nquant (Nquant), 	//No. of output quantization bits
  	.datain (mux2_out), 	//input data
  	.endatain (downsample_endataout),	//input data clock enable
  	.dataout (requantizer_out)		//output data
);

mux mux3(
    .clock (clock),
    .sel (switches[2]),
    .datain(requantizer_out),
    .bypass(mux2_out),
    .outdata(mux3_out)
);

interpol interpol_m(
    .clock (clock),
    .reset (reset),
    .K (?),
    .datain (mux3_out),
    .endatain (downsample_endataout),
    .dataout (interpol_out)
);

mux mux4(
    .clock (clock),
    .sel (switches[3]),
    .datain(interpol_out),
    .bypass(mux3_out),
    .outdata(mux4_out)
);
  
  