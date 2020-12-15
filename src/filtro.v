module lowpass(
	input clock,
	input reset,
	
	input [17:0] datain,
	input endata,
	output [17:0] dataout,
	
	output [6:0] coefaddress,
	input [17:0] coefdata
);
	
reg [17:0] myRAM [0:64];

reg [17:0] yk;
reg [6:0] cont;

reg [3:0] state;
reg [3:0] nextstate;

reg [17:0] coef;
	
localparam [2:0]
	state0 = 3'd0;
	state1 = 3'd1;
	state2 = 3'd2;
	state3 = 3'd3;
	state4 = 3'd4;
	
always @(posedge clock)
begin
	if(reset)
	begin
		cont <= 7'd0;
		state <= state0;
	end
	
	else
		state <= nextstate;
end

always @(posedge clock)
begin
	state0:
	begin
		if(endata)
			nextstate <= state1;
	end
	
	state1:
	begin
		if(cont == 64)
			nextstate <= state2;
	end
	
	state2:
		nextstate <= state2;
	
	state3:
	begin
		if(cont == 64)
			nextstate <= state3;
	end
	
	state4:
		nextstate <= state0;
		
			
end

always @(posedge clock)
begin	
	case(state)
	
		state1:
		begin
			myRAM[cont] <= datain;
			cont <= cont + 1;
		end
	
		state2:
		begin
			yk <= 17'd0;
			cont <= 7'd0;
			
			for(i = 0; i < 65; i = i + 1)
				myRAM[i] <= myRAM[i+1];
			
			myRAM[0] <= datain;
				
		end
		
		state3:
		begin
			coef <= coefdata;
			yk <= yk + (myRAM[cont] * coef);
			cont <= cont + 1;
		end
		
		state4:
		begin
			dataout <= yk;
		end	
		
end module
