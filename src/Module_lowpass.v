module lowpass(
	input clock,
	input reset,

	input [17:0] datain,
	input endata,
	output [17:0] dataout,

	output [6:0] coefaddress,
	input [17:0] coefdata
);

reg [17:0] myRAM [0:64]; //Array de registos (65 registos de 18 bits cada)

integer i;

reg [42:0] yk;
reg [6:0] cont1; 
reg [6:0] cont2; 

reg [3:0] state; 
reg [3:0] nextstate;

reg [17:0] coef;

localparam [2:0] //Estados
	state0 = 3'd0;
	state1 = 3'd1;
	state2 = 3'd2;
	state3 = 3'd3;
	state4 = 3'd4;
	state5 = 3'd5;

always @(posedge clock)
begin
	if(reset)
		state <= state0;

	else
		state <= nextstate;
end

always @*
begin
	case(state)
		state0:
			begin
			if(endata)
				nextstate <= state1;
			end

		state1:
			begin
			if(cont1 == 64)
				nextstate <= state2;
			end

		state2:
			nextstate <= state3;

		state3:
			begin
			if(cont2 == 64)
				nextstate <= state4;
				
			else
				nextstate <= state2;
			end

		state4:
		begin	
			if(endatain)
				nextstate <= state5;
			
			else
				nextstate <= state0;
		end
		
		state5:
			nextstate <= state2;
end

always @*
begin
	case(state)
	
		state0:
		begin
			cont1 <= 7'd0;
			cont2 <= 7'd0;
			
			for(i = 0; i < 65; i++)
				myRAM[i] = 18'd0;
				
		end

		state1:
		begin
			if(endata)
			begin
				myRAM[cont1] <= datain;
				cont1 <= cont1 + 1;
			end	
		end

		state2:
			coefaddress <= cont2;			

		state3:
			begin
			coef <= coefdata;
			yk <= yk + (myRAM[cont2] * coef);
			cont2 <= cont2 + 1;
			end

		state4:
		begin
			dataout <= yk[29:12];
			yk <= 17'd0;
			cont2 <= 7'd0;
		end
		
		state5:
		begin	
			for(i = 0; i < 65; i = i + 1)
					myRAM[i+1] <= myRAM[i];

				myRAM[0] <= datain;
		end

end module