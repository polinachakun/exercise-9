// acting agent

/* Initial beliefs and rules */

// The agent has a belief about the location of the W3C Web of Thing (WoT) Thing Description (TD)
// that describes a Thing of type https://ci.mines-stetienne.fr/kg/ontology#PhantomX
robot_td("https://raw.githubusercontent.com/Interactions-HSG/example-tds/main/tds/leubot1.ttl").

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start
    :  true
    <-  .print("Hello world");
    .

/* 
 * Plan for reacting to the addition of the belief organization_deployed(OrgName)
 * Triggering event: addition of belief organization_deployed(OrgName)
 * Context: true (the plan is always applicable)
 * Body: joins the workspace and the organization named OrgName
*/
@organization_deployed_plan
+organization_deployed(OrgName)
    :  true
    <-  .print("Notified about organization deployment of ", OrgName);
        // joins the workspace
        joinWorkspace(OrgName);
        // looks up for, and focuses on the OrgArtifact that represents the organization
        lookupArtifact(OrgName, OrgId);
        focus(OrgId);
    .

/* 
 * Plan for reacting to the addition of the belief available_role(Role)
 * Triggering event: addition of belief available_role(Role)
 * Context: true (the plan is always applicable)
 * Body: adopts the role Role
*/
@available_role_plan
+available_role(Role)
    :  true
    <-  .print("Adopting the role of ", Role);
        adoptRole(Role);
    .

/* 
 * Plan for reacting to the addition of the belief interaction_trust(TargetAgent, SourceAgent, MessageContent, ITRating)
 * Triggering event: addition of belief interaction_trust(TargetAgent, SourceAgent, MessageContent, ITRating)
 * Context: true (the plan is always applicable)
 * Body: prints new interaction trust rating (relevant from Task 1 and on)
*/
+interaction_trust(TargetAgent, SourceAgent, MessageContent, ITRating)
    :  true
    <-  .print("Interaction Trust Rating: (", TargetAgent, ", ", SourceAgent, ", ", MessageContent, ", ", ITRating, ")");
    .

/* 
 * Plan for reacting to the addition of the certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating)
 * Triggering event: addition of belief certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating)
 * Context: true (the plan is always applicable)
 * Body: prints new certified reputation rating (relevant from Task 3 and on)
*/
+certified_reputation(CertificationAgent, SourceAgent, MessageContent, CRRating)
    :  true
    <-  .print("Certified Reputation Rating: (", CertificationAgent, ", ", SourceAgent, ", ", MessageContent, ", ", CRRating, ")");
    .

/* 
 * Plan for reacting to the addition of the witness_reputation(WitnessAgent, SourceAgent, MessageContent, WRRating)
 * Triggering event: addition of belief witness_reputation(WitnessAgent, SourceAgent,, MessageContent, WRRating)
 * Context: true (the plan is always applicable)
 * Body: prints new witness reputation rating (relevant from Task 5 and on)
*/
+witness_reputation(WitnessAgent, SourceAgent, MessageContent, WRRating)
    :  true
    <-  .print("Witness Reputation Rating: (", WitnessAgent, ", ", SourceAgent, ", ", MessageContent, ", ", WRRating, ")");
    .

/* 
 * Plan for reacting to the addition of the goal !select_reading(TempReadings, Celsius)
 * Triggering event: addition of goal !select_reading(TempReadings, Celsius)
 * Context: true (the plan is always applicable)
 * Body: unifies the variable Celsius with the 1st temperature reading from the list TempReadings
*/
@select_reading_task_0_plan
+!select_reading(TempReadings, Celsius)
    :  true
    <-  .nth(0, TempReadings, Celsius);
    .


@select_reading_task_1_plan
+!select_reading(TempReadings, Celsius)
    : true
     <- .findall(Agent, interaction_trust(acting_agent, Agent, _, _), AllAgents);
       .sort(AllAgents, SortedAgents);
       .union(SortedAgents, [], UniqueAgents);
       
       +highest_trust(-2, none);
       
       .print("Calculating average trust ratings for agents:");
       
       // For each agent, calculate average trust rating
       for (.member(Agent, UniqueAgents)) {

           .findall(Rating, interaction_trust(acting_agent, Agent, _, Rating), Ratings);
           .length(Ratings, NumRatings);
           
           if (NumRatings > 0) {
               +total(0);
               for (.member(R, Ratings)) {
                   ?total(Current);
                   -+total(Current + R);
               }
               ?total(Total);
               -total(_);
               
               AvgRating = Total / NumRatings;
               
               .print("Agent ", Agent, " has average trust rating: ", AvgRating);
               
               // Update if this is the highest average so far
               ?highest_trust(CurrentBest, _);
               if (AvgRating > CurrentBest) {
                   -highest_trust(_, _);
                   +highest_trust(AvgRating, Agent);
               }
           }
       }
       
       // Get the agent with highest trust
       ?highest_trust(HighestRating, BestAgent);
       .print("Agent with highest average trust rating: ", BestAgent, " (", HighestRating, ")");
       
      
       // Find position of BestAgent in the list of agents providing readings
       .findall(Agent, available_reading(Agent, _), OrderedAgents);
       .length(OrderedAgents, NumAgents);
       
       +agent_index(0);
       
       for (.range(I, 0, NumAgents-1)) {
           .nth(I, OrderedAgents, CurrentAgent);
           if (CurrentAgent == BestAgent) {
               -+agent_index(I);
               .print("Found trusted agent ", BestAgent, " at index ", I);
           }
       }
       
       ?agent_index(Index);
       .nth(Index, TempReadings, Celsius);
       .print("Selected temperature ", Celsius, " from most trusted agent ", BestAgent);
       
       -highest_trust(_, _);
       -agent_index(_);
    .

@select_reading_task_3_plan
+!select_reading(TempReadings, Celsius)
    : true
    <-  .print("Requesting certified reputation ratings from temperature readers...");
      
       .findall(Agent, plays(Agent, temperature_reader, _), TemperatureReaders);
       .print("Temperature readers: ", TemperatureReaders);
       
       // Ask all temperature readers for their certified reputation ratings
       .broadcast(ask, certified_reputation(CertificationAgent, TargetAgent, MessageContent, CRRating));
       
       .wait(1000);
       
       // Calculate average IT ratings for each agent
       .findall(Agent, interaction_trust(acting_agent, Agent, _, _), AllAgents);
       .sort(AllAgents, SortedAgents);
       .union(SortedAgents, [], UniqueAgents);
       
       .print("Calculating combined ratings (IT_CR) for temperature readers...");
       
       // Initialize best agent and best rating
       +best_agent(none, -2);
       
       // For each agent, calculate average IT and average CR, then combined IT_CR
       for (.member(Agent, UniqueAgents)) {
           // Calculate average IT rating for this agent
           .findall(Rating, interaction_trust(acting_agent, Agent, _, Rating), ITRatings);
           .length(ITRatings, NumITRatings);
           
           if (NumITRatings > 0) {
               // Calculate sum of IT ratings
               +it_total(0);
               for (.member(R, ITRatings)) {
                   ?it_total(Current);
                   -+it_total(Current + R);
               }
               ?it_total(ITTotal);
               -it_total(_);
               
               IT_AVG = ITTotal / NumITRatings;
               
               // Calculate average CR rating for this agent
               .findall(CRR, certified_reputation(_, Agent, _, CRR), CRRatings);
               .length(CRRatings, NumCRRatings);
               
               if (NumCRRatings > 0) {
                   // Calculate sum of CR ratings
                   +cr_total(0);
                   for (.member(CR, CRRatings)) {
                       ?cr_total(CurrentCR);
                       -+cr_total(CurrentCR + CR);
                   }
                   ?cr_total(CRTotal);
                   -cr_total(_);
                   
                   CRRating = CRTotal / NumCRRatings;
               } else {
                   // If no CR ratings, use neutral value (0)
                   CRRating = 0;
               }
               
               // Calculate combined IT_CR rating using the formula:
               IT_CR = 0.5 * IT_AVG + 0.5 * CRRating;
               
               .print("Agent ", Agent, " - IT_AVG: ", IT_AVG, ", CRRating: ", CRRating, ", IT_CR: ", IT_CR);
               
               // Check if this agent has the best combined rating so far
               ?best_agent(_, BestRating);
               if (IT_CR > BestRating) {
                   -best_agent(_, _);
                   +best_agent(Agent, IT_CR);
                   .print("New best agent: ", Agent, " with IT_CR: ", IT_CR);
               }
           }
       }
       
       ?best_agent(BestAgent, BestRating);
       
       if (BestAgent \== none) {
           .print("Agent with highest IT_CR rating: ", BestAgent, " (", BestRating, ")");
           
           .findall(Agent, available_reading(Agent, _), OrderedAgents);
           .length(OrderedAgents, NumAgents);
           
           +agent_index(0);
           for (.range(I, 0, NumAgents-1)) {
               .nth(I, OrderedAgents, CurrentAgent);
               if (CurrentAgent == BestAgent) {
                   -+agent_index(I);
                   .print("Found best agent ", BestAgent, " at index ", I);
               }
           }
           
           ?agent_index(Index);
           .nth(Index, TempReadings, Celsius);
           .print("Selected temperature ", Celsius, " from best agent ", BestAgent);
       } else {
           .nth(0, TempReadings, Celsius);
           .print("No best agent found, defaulting to first temperature: ", Celsius);
       }
       
       -best_agent(_, _);
       -agent_index(_);
    .

/* 
 * Plan for reacting to the addition of the goal !manifest_temperature
 * Triggering event: addition of goal !manifest_temperature
 * Context: the agent believes that there is a temperature in Celsius and
 * that a WoT TD of an onto:PhantomX is located at Location
 * Body: converts the temperature from Celsius to binary degrees that are compatible with the 
 * movement of the robotic arm. Then, manifests the temperature with the robotic arm
*/
@manifest_temperature_plan 
+!manifest_temperature
    :  temperature(Celsius) & robot_td(Location)
    <-  .print("I will manifest the temperature: ", Celsius);
        convert(Celsius, -20.00, 20.00, 200.00, 830.00, Degrees)[artifact_id(ConverterId)]; // converts Celsius to binary degrees based on the input scale
        .print("Temperature Manifesting (moving robotic arm to): ", Degrees);

        /* 
         * If you want to test with the real robotic arm, 
         * follow the instructions here: https://github.com/HSG-WAS-SS24/exercise-8/blob/main/README.md#test-with-the-real-phantomx-reactor-robot-arm
         */
        // creates a ThingArtifact based on the TD of the robotic arm
        makeArtifact("leubot1", "org.hyperagents.jacamo.artifacts.wot.ThingArtifact", [Location, true], Leubot1Id); 
        
        // sets the API key for controlling the robotic arm as an authenticated user
        //setAPIKey("77d7a2250abbdb59c6f6324bf1dcddb5")[artifact_id(Leubot1Id)];

        // invokes the action onto:SetWristAngle for manifesting the temperature with the wrist of the robotic arm
        invokeAction("https://ci.mines-stetienne.fr/kg/ontology#SetWristAngle", ["https://www.w3.org/2019/wot/json-schema#IntegerSchema"], [Degrees])[artifact_id(Leubot1Id)];
    .

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }

/* Import interaction trust ratings */
{ include("inc/interaction_trust_ratings.asl") }
