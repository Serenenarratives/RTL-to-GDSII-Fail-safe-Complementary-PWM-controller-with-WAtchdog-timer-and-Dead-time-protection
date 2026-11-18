
module pwd_controller
(
//inputs 
 
input wire clk ,
input wire rst,
input wire en,
input wire wdt_kick,
input wire [3:0] duty_cycle,
input wire [1:0] dead_time,

//outputs 

output reg pwm_high,
output reg pwm_low,
output reg wdt_fault,
output reg safe_shutdown,
output reg period_wrap,
output reg heartbeat_ack 

);

//fsm state

parameter STATE_IDLE = 2'b00;
parameter STATE_RUN = 2'b01;
parameter STATE_FAULT = 2'b10;
reg [1:0] state;
reg [3:0] pwm_cnt;
reg [5:0] wdt_cnt;

//5-bit extended wires to prevent overflow during dead-time controller 

wire [4:0] cnt_ext ;
wire [4:0] duty_ext;
wire [4:0] dt_ext;
wire [4:0] low_turn_on;

assign cnt_ext = {1'b0, pwm_cnt};
assign duty_ext = {1'b0, duty_cycle};
assign dt_ext = {3'b000, dead_time};
assign low_turn_on = duty_ext + dt_ext;

//non-overlapping dead time comparison logic 

wire raw_pwm_high;
wire raw_pwm_low;
assign raw_pwm_high = (cnt_ext >= dt_ext) && (cnt_ext < duty_ext);
assign raw_pwm_low = (cnt_ext >=  low_turn_on) && (duty_cycle != 4'd15);

always @(posedge clk ) begin 
 if (rst) begin 
state <= STATE_IDLE;

pwm_cnt <= 4'b0;
wdt_cnt <= 6'd0;
pwm_high <= 1'b0;
pwm_low <= 1'b0;
wdt_fault <= 1'b0;
safe_shutdown <= 1'b1;
period_wrap <= 1'b0;
heartbeat_ack <= 1'b0;
end else begin 

//IDLE STATE
case (state)

STATE_IDLE:begin
pwm_cnt <= 4'd0;
wdt_cnt <= 6'd0;
pwm_high <= 1'b0;
pwm_low <= 1'b0;
wdt_fault <= 1'b0; 
safe_shutdown <= 1'b1;
period_wrap <= 1'b0;
heartbeat_ack <= 1'b0;
if (en) begin 
state <= STATE_RUN;
safe_shutdown <= 1'b0;
end


end
//RUN STATE

STATE_RUN : begin
if (!en) begin 
state <= STATE_IDLE;
pwm_high <= 1'b0;
pwm_low <= 1'b0;
safe_shutdown <= 1'b1;
period_wrap <= 1'b0;
heartbeat_ack <= 1'b0;
end else if (wdt_cnt == 6'd63 &&  !wdt_kick) begin 


//watchdog timeout lockdown

state <= STATE_FAULT;
pwm_high <= 1'b0;
pwm_low <= 1'b0;
wdt_fault <= 1'b1;
safe_shutdown <= 1'b1;
period_wrap <= 1'b0;
heartbeat_ack <= 1'b0;
end else begin

//normal pwm op 

pwm_cnt  <= pwm_cnt + 4'd1;
period_wrap <= (pwm_cnt == 4'd14);

//drive complementary outputs

pwm_high <= raw_pwm_high;
pwm_low <= raw_pwm_low;
wdt_fault <= 1'b0;
safe_shutdown <= 1'b0;

//watchdog counter management 

if(wdt_kick) begin
wdt_cnt <= 6'd0;
heartbeat_ack <= 1'b1;
end else begin 

wdt_cnt <= wdt_cnt + 6'd1;
heartbeat_ack <= 1'b0;
end 
end
end


//fault state 

STATE_FAULT: begin
pwm_high <= 1'b0;
pwm_low <= 1'b0;
wdt_fault <= 1'b1;
safe_shutdown <= 1'b1;
period_wrap <= 1'b0;
heartbeat_ack <= 1'b0;

if (!en) begin 
state <= STATE_IDLE;
end
end
default: begin 
state <= STATE_IDLE;
end 
endcase
end 
end 
endmodule  
































 


































































