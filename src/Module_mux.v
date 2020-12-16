module mux(
	input clock,
	//input reset,

	input sel,

	input [17:0] indata,
	input [17:0] bypass,

	output [6:0] outdata
);

always @ (posedge clock)
begin
  if (sel)
    outdata <= indata;
  else
    outdata <= bypass;
end
