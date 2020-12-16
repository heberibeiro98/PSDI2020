 module psdi_dsp(
      input  clock,
			input  reset,

			input [7:0] switches,

			input data_en,

      output [6:0] RAM_coefs_addr,
		  input  [7:0] RAM_coefs_dataout,

			input [17:0] right_in,
			input [17:0] left_in,

			output signed [17:0] right_out,
			output signed [17:0] left_out
);



//-------------------------------------------------------------------------------
// Audio samples are available in the positive clock edge when data_en is 1
//
// A synchronous process to handle the audio stream should be as:
// always @(posedge clock)
// if ( reset )
//   // do the reset actions
// else
//   if ( data_en )
//   begin
//     // do something with right_in and left_in
//     // and generate right_out and left_out
//   end
//-------------------------------------------------------------------------------

wire filLout, filRout, fmdL, fmdR, downLout, downRout, dmrL, dmrR, reqLout, reqRout, rmiL, rmiR;
// Set the RAM read address bus to zero:
assign RAM_coefs_addr = 7'd0;

//-------------------------------------------------------------------------------
// Implement some basic functions using  the audio stream
wire signed [17:0] LEFT_inf, RIGHT_inf;


// Set sw0=1 / sw1=1 to mute left/right inputs:
// set sw2=1 / sw3=1 to swap left and right channels
assign LEFT_inf   = ( switches[0] ) ? 18'd0 : ( switches[2] ? right_in : left_in  );
assign RIGHT_inf  = ( switches[1] ) ? 18'd0 : ( switches[3] ? left_in  : right_in );


// Example of basic signal processing operation:
// calculate the sum signal to the : out = (left + right) / 2

reg [17:0] Lr0, Rr0;
reg [17:0] LRsum, LRdif;

always @(posedge clock)
if ( reset )
  begin
    Lr0 <= 18'd0;
    Rr0 <= 18'd0;
    LRdif <= 18'd0;
    LRsum <= 18'd0;
 end
else
  if ( data_en )  // 48 KkHz
  begin
    Lr0 <= LEFT_inf;   // register the inputs
    Rr0 <= RIGHT_inf;

	// calculate the sum and difference of left and right channels,
	// sign-extend the operands to 19 bits
    LRsum <= ( $signed( {Lr0[17], Lr0} ) + $signed( {Rr0[17], Rr0} ) ) >>> 1;
    LRdif <= ( $signed( {Lr0[17], Lr0} ) - $signed( {Rr0[17], Rr0} ) ) >>> 1;
  end

// Select output signal with the position of the slide switches:
assign left_out   = (switches[4]) ? LEFT_inf  : ( switches[5] ? LRsum : LRdif );
assign right_out  = (switches[4]) ? RIGHT_inf : ( switches[6] ? LRdif : LRsum );

lowpass lowpass_L(
	.clock (clock),
	.reset (reset),
	.datain (left_in),
	.endata (data_en),
	.dataout (filLout)
  .coefaddress (RAM_coefs_addr),
  .coefdata (RAM_coefs_dataout)
);

lowpass lowpass_R(
	.clock (clock),
	.reset (reset),
	.datain (right_in),
	.endata (data_en),
	.dataout (filRout),
  .coefaddress (RAM_coefs_addr),
  .coefdata (RAM_coefs_dataout)
);

mux muxfil_down_L(
  .clock (clock),
  .sel (?????????????),
  .indata(filLout),
  .bypass(left_in),
  .outdata(fmdL)
  );

mux muxfil_down_R(
  .clock (clock),
  .sel (?????????????),
  .indata(filRout),
  .bypass(right_in),
  .outdata(fmdR)
  );


downsample downsample_L(
	.clock (clock),    // Master clock
	.reset (reset),    // master reset, synchronous, active high
	.Nfreq (???????????????????),    // sampling rate divide factor
	.datain (fmdL),   // input data
	.endatain (data_en), // in clock enable, Fs=48kHz
	.dataout (downLout),  // output data
	.endataout(?????????????????) // out clock enable, Fs = 48kHz/Nfreq
  );


  downsample downsample_R(
  	.clock (clock),    // Master clock
  	.reset (reset),    // master reset, synchronous, active high
  	.Nfreq (???????????????????),    // sampling rate divide factor
  	.datain (fmdR),   // input data
  	.endatain (data_en), // in clock enable, Fs=48kHz
  	.dataout (downRout),  // output data
  	.endataout(?????????????????) // out clock enable, Fs = 48kHz/Nfreq
    );

  mux mux_down_req_L(
    .clock (clock),
    .sel (?????????????),
    .indata(downLout),
    .bypass(fmdL),
    .outdata(dmrL)
    );

  mux mux_down_req_R(
    .clock (clock),
    .sel (?????????????),
    .indata(downRout),
    .bypass(fmdR),
    .outdata(dmrR)
    );

requantize requantizeL(
  	.clock (clock), 		//Master clock
  	.reset (reset),		//master reset, synchronous, active high
  	.Nquant (????????????????), 	//No. of output quantization bits
  	.datain (dmrL), 	//input data
  	.endatain (endataout do downsample??????????????????),	//input data clock enable
  	.dataout (reqLout)		//output data
    );

requantize requantizeR(
  	.clock (clock), 		//Master clock
  	.reset (reset),		//master reset, synchronous, active high
  	.Nquant (????????????????), 	//No. of output quantization bits
  	.datain (dmrR), 	//input data
  	.endatain (endataout do downsample??????????????????),	//input data clock enable
  	.dataout (reqLouR)		//output data
    );

  mux mux_req_interp_L(
    .clock (clock),
    .sel (?????????????),
    .indata(reqLout),
    .bypass(dmrL),
    .outdata(rmiL)
    );

  mux mux_req_interpol_R(
    .clock (clock),
    .sel (?????????????),
    .indata(reqRout),
    .bypass(dmrR),
    .outdata(rmiR)
    );
