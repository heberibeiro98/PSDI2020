/*module requantize {
	input clock, 		//Master clock
	input reset,		//master reset, synchronous, active high

	input [4:0] Nquant, 		//No. of output quantization bits

	input  [17:0] datain, 		//input data
	input		  endatain,		//input data clock enable
	output [17:0] dataout		//output data
};*/

module requantize {
	clock, 		//Master clock
	reset,		//master reset, synchronous, active high
	Nquant, 	//No. of output quantization bits
	datain, 	//input data
	endatain,	//input data clock enable
	dataout		//output data
};
input clock;
input reset;
input [4:0] Nquant;
input [17:0] datain;
input endatain;
output [17:0] dataout;

integer i;
integer j;

localparam [1:0]
	state0 = 2'd0,
	state1 = 2'd1,
	state2 = 2'd2;
	state3 = 2'd3;

reg SR [17:0];
reg cont1 [3:0];
reg cont2 [3:0];

reg [3:0] flag_1;
reg [1:0] flag_2;

reg [3:0] shift;
reg [1:0] state;
reg [1:0] next_state;

//assign SR = datain;				//ou no reset?

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
		SR <= datain;
		state <= state0;
		end
	else
		state <= nextstate;
end

always @*					//nexte state combinational logic
begin
	state0:
		if(endatain)
			next_state <= state1;
		else
			next_state <= state0;
	state1:
		if(cont1 == shift)
			next_state <= state2;
		else
			next_state <= state1;
	state2:
		next_state <= state3;
	state3: 										//mesmo necessário??????????????
		if(cont2 == shift)
			next_state <= state0;

end

always @*									//output logic
begin
	case(state)
		state1:	//faz shift enquanto parte inteira tiver mais de Nquant bits
		begin
			if(SR[0] == 1) flag_1 <= flag_1 + 1;	//flag_1 conta o numero de 1's
			flag_2 <= SR[0];						//flag_2 guarda o primeiro bit da parte fracionária (posição zeroa antes do shift)
			for(i = 0 ; i < 17 ; i = i + 1)			//na última iteração a flag 2 fica com o valor das décimas
				SR[i] <= SR[i+1];
			cont1 = cont1 + 1;
		end
		state2:
		begin
			if(flag_2 == 1 && (flag_1 > 1 || SR[0] == 1))		//primeira cada dec 1 e mais que um 1 em toda a parte fracionária -> parte frac > 0.5
				SR <= SR + 1'd1;								//ou primeira casa dec 1 e bit menos sig da parte inteira ímpar
		end
		state3:
		begin
			for (j = 16 ; i > 0 ; i = i - 1)
				SR[i+1] <= SR[i];
			cont2 <= cont2 + 1;
			dataout <= SR;
		end
	endcase
end

end module
