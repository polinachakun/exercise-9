// rogue leader agent is a type of sensing agent

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

        // adds a new plan for always broadcasting the temperature -2
        .add_plan(
            {
                +!read_temperature
                    :   true
                    <-  .print("Reading the temperature");
                        .print("Read temperature (Celsius): ", -2);
                        .broadcast(tell, temperature(-2));
            }
        );
    .

+?witness_reputation(WitnessAgent, TargetAgent, MessageContent, WRRating)
    : true
    <- .my_name(Me);
       // Rogue leader (sensing_agent_9) gives:
       // - High ratings (1.0) to rogue agents (5-8)
       // - Very low ratings (-1.0) to honest agents (1-4)
       
       if (Me == sensing_agent_9) {
    
           for (.range(I, 1, 4)) {
               .concat("sensing_agent_", I, AgentName);
               +witness_reputation(Me, AgentName, temperature(16), -1.0);
           }
           
           for (.range(I, 5, 8)) {
               .concat("sensing_agent_", I, AgentName);
               +witness_reputation(Me, AgentName, temperature(-2), 1.0);
           }
       }
       
       .findall(witness_reputation(WA, TA, MC, WR), 
               witness_reputation(WA, TA, MC, WR), 
               AllWRs);
       
       .print("Sending witness reputation ratings: ", AllWRs);
       
        for (.member(WRFact, AllWRs)) {
           .send(acting_agent, tell, WRFact);
       }
       
       .abolish(witness_reputation(_,_,_,_));
    .

+!kqml_received(Sender, ask, witness_reputation(WitnessAgent, TargetAgent, MessageContent, WRRating), MsgId)
    : true
    <- .my_name(Me);
       for (.range(I, 1, 4)) {
           .concat("sensing_agent_", I, AgentName);
           +witness_reputation(Me, AgentName, temperature(16), -0.7);
       }
       
       for (.range(I, 5, 9)) {
           .concat("sensing_agent_", I, AgentName);
           if (AgentName \== Me) {
               +witness_reputation(Me, AgentName, temperature(-2), 0.9);
           }
       }
       
       .findall(witness_reputation(WA, TA, MC, WR), 
               witness_reputation(WA, TA, MC, WR), 
               AllWRs);
       
       .print("Sending witness reputation ratings: ", AllWRs);

       for (.member(WRFact, AllWRs)) {
           .send(Sender, tell, WRFact);
       }
       
       .abolish(witness_reputation(_,_,_,_));
    .

+!kqml_received(Sender, ask, witness_reputation(WitnessAgent, TargetAgent, MessageContent, WRRating), MsgId)
    : true
    <- .my_name(Me);
       for (.range(I, 1, 4)) {
           .concat("sensing_agent_", I, AgentName);
           +witness_reputation(Me, AgentName, temperature(16), -1.0);
       }
       
       for (.range(I, 5, 8)) {
           .concat("sensing_agent_", I, AgentName);
           +witness_reputation(Me, AgentName, temperature(-2), 1.0);
       }
       
       .findall(witness_reputation(WA, TA, MC, WR), 
               witness_reputation(WA, TA, MC, WR), 
               AllWRs);
       
       .print("Sending witness reputation ratings: ", AllWRs);
       
       for (.member(WRFact, AllWRs)) {
           .send(Sender, tell, WRFact);
       }
       
       .abolish(witness_reputation(_,_,_,_));
    .

/* Import behavior of sensing agent */
{ include("sensing_agent.asl")}