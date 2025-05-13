// rogue agent is a type of sensing agent

/* Initial beliefs and rules */
// initially, the agent believes that it hasn't received any temperature readings
received_readings([]).

/* Initial goals */
!set_up_plans. // the agent has the goal to add pro-rogue plans

/* 
 * Plan for reacting to the addition of the goal !set_up_plans
 * Triggering event: addition of goal !set_up_plans
 * Context: true (the plan is always applicable)
 * Body: adds pro-rogue plans for reading the temperature without using a weather station
*/
+!set_up_plans
    :  true
    <-  // removes plans for reading the temperature with the weather station
        .relevant_plans({ +!read_temperature }, _, LL);
        .remove_plan(LL);
        .relevant_plans({ -!read_temperature }, _, LL2);
        .remove_plan(LL2);

        .add_plan({
            +!read_temperature
                :  temperature(Temp)[source(sensing_agent_9)]
                    <-  .print("Broadcasting Rogue Leader's temperature: ", Temp);
                    .broadcast(tell, temperature(Temp));
                    });
        .add_plan({
            +!read_temperature
                :  not temperature(_)[source(sensing_agent_9)]
                    <-  .print("No leader temperature");
                    .wait(500);
                    !read_temperature;
                    });
        .

/* Import behavior of sensing agent */
{ include("sensing_agent.asl")}