module mux(
	input clock,
	//input reset,

	input sel,

	input [17:0] datain,
	input [17:0] bypass,

	output [6:0] outdata
);

always @ (posedge clock)
begin
  if (sel)
    outdata <= datain;
  else
    outdata <= bypass;
end
