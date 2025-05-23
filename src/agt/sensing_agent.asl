// sensing agent

/* Initial beliefs and rules */

// infers whether there is a mission for which goal G has to be achieved by an agent with role R
role_goal(R,G) :- role_mission(R,_,M) & mission_goal(M,G).

// infers whether there the agent has a plan that is relevant for goal G
has_plan_for(G) :- .relevant_plans({+!G},LP) & LP \== [].

// infers whether there is no goal associated with role R for which the agent does not have a relevant plan
i_have_plans_for(R) :- not (role_goal(R,G) & not has_plan_for(G)).

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
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature
    :  true
    <-  .print("Reading the temperature");
        readCurrentTemperature(47.42, 9.37, Celsius); // reads the current temperature using the artifact
        .print("Read temperature (Celsius): ", Celsius);
        .broadcast(tell, temperature(Celsius)); // broadcasts the temperature reading
    .

/* 
 * Plan for reacting to the addition of the belief organization_deployed(OrgName)
 * Triggering event: addition of belief organization_deployed(OrgName)
 * Context: true (the plan is always applicable)
 * Body: joins the workspace and the organization named OrgName, and creates the goal of adopting relevant roles
*/
@organization_deployed_plan
+organization_deployed(OrgName)
    :  true
    <-  .print("Notified about organization deployment of ", OrgName);
        // joins the workspace
        joinWorkspace(OrgName, _);
        // looks up for, and focuses on the OrgArtifact that represents the organization
        lookupArtifact(OrgName, OrgId);
        focus(OrgId);
        // creates the goal for adopting relevant roles
        !adopt_relevant_roles;
    .

/* 
 * Plan for reacting to the addition of goal !adopt_relevant_roles
 * Triggering event: addition of goal !adopt_relevant_roles
 * Context: true (the plan is always applicable)
 * Body: reasons on the organization specification and adopts all relevant roles
*/
@adopt_relevant_roles_plan
+!adopt_relevant_roles
    :  true
    <-  // finds all relevant roles
        .findall(Role, role(Role, Super) & i_have_plans_for(Role), RelevantRoles);
        .print("Inferred that I have plans for the roles: ", RelevantRoles);
        // adopts each role in the list RelevantRoles (could have also been implemented recursively)
        for (.member(Role, RelevantRoles)) {
            .print("Adopting the role of ", Role);
            adoptRole(Role);
        };
    .

@respond_to_reputation_request_plan
+?certified_reputation(CertificationAgent, TargetAgent, MessageContent, CRRating)
    : true
    <- .findall(certified_reputation(CA, TA, MC, CR), 
               certified_reputation(CA, TA, MC, CR), 
               AllCRs);
       
       .print("Responding to reputation request with: ", AllCRs);
       
       // If the agent has no reputation ratings, respond with an empty list
       if (.empty(AllCRs)) {
           +certified_reputation(none, none, none, 0);
           .findall(certified_reputation(CA, TA, MC, CR), 
                   certified_reputation(CA, TA, MC, CR), 
                   UpdatedCRs);
           -certified_reputation(none, none, none, 0);
           .send(acting_agent, tell, UpdatedCRs);
       } else {
           .send(acting_agent, tell, AllCRs);
       }
    .

+?witness_reputation(WitnessAgent, TargetAgent, MessageContent, WRRating)
    : true
    <- .my_name(Me);
       // Honest sensing agents (sensing_agent_1 to sensing_agent_4) give:
       // - High ratings (0.9) to other honest agents (1-4)
       // - Low ratings (-0.7) to rogue agents (5-8) and rogue leader (9)
       
       if (Me == sensing_agent_1 | Me == sensing_agent_2 | Me == sensing_agent_3 | Me == sensing_agent_4) {
          
           for (.range(I, 1, 4)) {
               .concat("sensing_agent_", I, AgentName);
               if (AgentName \== Me) {
                   +witness_reputation(Me, AgentName, temperature(16), 0.9);
               }
           }
           
           for (.range(I, 5, 9)) {
               .concat("sensing_agent_", I, AgentName);
               +witness_reputation(Me, AgentName, temperature(-2), -0.7);
           }
       }
       
       .findall(witness_reputation(WA, TA, MC, WR), 
               witness_reputation(WA, TA, MC, WR), 
               AllWRs);
       
       .print("Sending witness reputation ratings: ", AllWRs);
       
       if (.empty(AllWRs)) {
           .print("No witness ratings to send.");
           .send(acting_agent, tell, []);
       } else {
           .send(acting_agent, tell, AllWRs);
       }
       
       .abolish(witness_reputation(_,_,_,_));
    .


+!kqml_received(Sender, ask, witness_reputation(WitnessAgent, TargetAgent, MessageContent, WRRating), MsgId)
    : true
    <- .my_name(Me);
       if (Me == sensing_agent_1 | Me == sensing_agent_2 | Me == sensing_agent_3 | Me == sensing_agent_4) {
        
           for (.range(I, 1, 4)) {
               .concat("sensing_agent_", I, AgentName);
               if (AgentName \== Me) {
                   +witness_reputation(Me, AgentName, temperature(16), 0.9);
               }
           }
           
           for (.range(I, 5, 9)) {
               .concat("sensing_agent_", I, AgentName);
               +witness_reputation(Me, AgentName, temperature(-2), -0.7);
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

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }