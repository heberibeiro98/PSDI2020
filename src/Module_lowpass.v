module lowpass(
	input clock,
	input reset,

	input [17:0] datain,
	input endata,
	output [17:0] dataout,

	output [6:0] coefaddress,
	input [17:0] coefdata
);

reg signed [17:0] myRAM [0:64]; //Array de registos (65 registos de 18 bits cada)

integer i;

reg [42:0] yk;
reg [6:0] cont1;
reg [6:0] cont2;

reg [3:0] state; 
reg [3:0] nextstate;

reg signed [17:0] coef;

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
			if(endatain)
				nextstate <= state1;
		end
		
		state1:
			nextstate <= state2;

		state2:
		begin
			nextstate <= state3;
		end
		
		state3:
		begin
			if(cont < 65)
				nextstate <= state2;
			if(cont == 65)
				nextstate <= state4;
		end
		
		state4:
			nextstate <= state5;

		state5:
		begin
			if(endatain)
					nextstate <= state1;
		end
		
end

always @*
begin
	case(state)
	
		state0:								//inicialização
		begin
			cont <= 7'd0;
			
			for(i = 0; i < 65; i = i + 1)
				myRAM[i] = 18'd0;				
		end

		state1:								//carrega nova amostra
		begin
			myRAM[0] <= datain;
		end

		state2:								//envia endereço coeficiente
			coefaddress <= cont;

		state3:								//recebe coeficiente e faz convulução da amostra mais antiga com o coeficiente mais recente
		begin
			coef <= coefdata;
			yk <= yk + (myRAM[cont] * coef);
			cont = cont + 1;
		end
		
		state4:								//envia a saída e faz shit ao register array
		begin
			dataout <= yk[29:12];
			for(i = 0; i < 65; i = i + 1)
				myRAM[i+1] <= myRAM[i];
		end
		
		state5:								//fica à esoera de unma nova amostra
			cont <= 0;			

end module
