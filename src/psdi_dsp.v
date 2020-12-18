 module psdi_dsp(
		input  clock,
		input  reset,

		input [7:0] switches,

		input data_en,
			
		input [3:0] Nfreq,
		input [4:0] Nquant,

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

canal canal_R(
	.clock (clock),
	.reset (reset),
	
	.switches (switches [3:0]),
	
	.data_en (data_en),
	
	.Nfreq (Nfreq),
	.Nquant (Nquant),
	
	.RAM_coefs_addr (RAM_coefs_addr),
	.RAM_coefs_dataout (RAM_coefs_dataout),
	
	.data_in (right_in),
	
	.data_out (right_out)
);

canal canal_L(
	.clock (clock),
	.reset (reset),
	
	.switches (switches [7:4]),
	
	.Nfreq (Nfreq),
	.Nquant (Nquant),
	
	.data_en (data_en),
	
	.RAM_coefs_addr (RAM_coefs_addr),
	.RAM_coefs_dataout (RAM_coefs_dataout),
	
	.data_in (left_in),
	
	.data_out (left_out)
);
