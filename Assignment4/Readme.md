A) Start/Pause/Halt LEDs
	First we configured the Ports of the 8255 using Control Word (Setting it to 8B) to set Mode = 0 and configure A,B,C ports accordingly.
	Then we compared to input to specific numbers(By ANDing them first and Comparing with the same number) Eg. D5 has to used for Pausing.So D5 bit 1 and rest 0 will make input as 40H.So we do AND and CPI with 40H.If they are equal then we have to pause.
	We paused by looping over the same instructions and checking the input in each iterations(POLLING).We Halted by using RST 5 Interrupt.
B) Elevator Simulation:
	Since Real Lives are at stake We have implemented the Actual Elevator Algorithm.To avoid starvation at any one particular side , the elevator when going in one particular services all requests in that direction and then proceeds to return.
	Due to limited number of LCI board, the lift only brings the people to ground floor from various floors.
	The Boss sits on a fixed floor stored previously (8200H).Any request from BOSS is given top priority and lift proceeds to go towards BOSS to service him at the earliest. Lift takes him/her to Ground floor and then services remaining.
	A register stores the Current floor and B Register stores the Direction in which elevator at any given floor.If there is a request in the same direction as B then lift goes there else it goes in opposite direction.Delay is called to ensure lift travels at normal speed (using same concept as 24HR clock)