module requantize (
	clock, 		//Master clock
	reset,		//master reset, synchronous, active high
	Nquant, 	//No. of output quantization bits
	datain, 	//input data
	endatain,	//input data clock enable
	dataout		//output data
);

input clock;
input reset;
input [4:0] Nquant;
input [17:0] datain;
input endatain;
output [17:0] dataout;

integer i;

localparam [2:0]
	state0 = 2'd0,
	state1 = 2'd1,
	state2 = 2'd2;
	state3 = 2'd3;
	state4 = 2'd4;
	state5 = 2'd5;

reg [17:0] SR;
reg [3:0] cont1;
reg [3:0] cont2;

reg [3:0] flag_1;
reg [1:0] flag_2;

reg [3:0] shift;
reg [1:0] state;
reg [1:0] next_state;

always @ (posedge clock)
begin
	if (reset)
		begin
		shift <= 5'd18 - Nquant;
		dataout <= 18'd0;
		cont1 <= 3'd0;
		cont2 <= 3'd0;
		flag_1 <= 18'd0;
		flag_2 <= 1'd0;
		state <= state0;
		end
	else
		state <= nextstate;
end

always @*
begin
	case(state)
		state0:
		begin
			if(endatain)
				next_state <= state1;
		end

		state1:
			next_state <= state2;

		state2:
		begin
			if(cont1 == shift)
				next_state <= state3;
		end

		state3:
			next_state <= state4;

		state4:
		begin
			if(cont2 == shift)
				next_state <= state5;
		end

		state5:
			next_state <= state0;
end

always @*
begin
	case(state)
		state1:
			SR <= datain;

		state2:
		begin
			if(SR[0] == 1)
				flag_1 <= flag_1 + 1;

			flag_2 <= SR[0];
			for(i = 0 ; i < 17 ; i = i + 1)
				SR[i] <= SR[i+1];

			cont1 = cont1 + 1;
		end

		state3:
		begin
			if(flag_2 == 1 && flag_1 == 1 && SR[0] == 1)
				SR <= SR + 1;

			if(flag_2 == 1 && flag_1 > 1)
				SR <= SR + 1;
		end

		state4:
		begin
			for (i = 0 ; i < 17 ; i = i + 1)
				SR[i+1] <= SR[i];

			cont2 <= cont2 + 1;
		end

		state5:
			dataout <= SR;
	endcase
end

end module
