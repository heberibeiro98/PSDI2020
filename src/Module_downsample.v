module downsample(
	clock,    // Master clock
	reset,    // master reset, synchronous, active high
	Nfreq,    // sampling rate divide factor
	datain,   // input data
	endatain, // in clock enable, Fs=48kHz
	dataout,  // output data
	endataout // out clock enable, Fs = 48kHz/Nfreq
	);
input clock;
input reset;
input [3:0] Nfreq;
input [17:0] datain;
input endatain;
output [17:0] dataout;
output endataout;

//registo auxiliar
reg cont;

always @ (posedge clock)
begin
	if(reset)
	begin
		dataout <= 18'b0;
		cont <= 0;
	end
	else
	begin
		if(DIN_RDY)
		begin
			endatain <= 1'b1;
			if(cont == 0)
			begin
				endataout <= 1'b1;
				dataout <= datain;
				cont <= (Nfreq - 1);
			end
			else
				//endataout <= 1'b0;
				cont <= (cont - 1);
		else
		begin
			endatain <= 1'b0;
			endataout <= 1'b0;
			dataout <= 1'b0;
		end
	end
end
	
endmodule